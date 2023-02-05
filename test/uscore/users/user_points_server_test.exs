defmodule UScore.Users.UserPointsServerTest do
  use UScore.DataCase, async: false
  alias UScore.Users.User
  alias UScore.Users.UserPointsServer
  alias UScore.Clock.Mock, as: ClockMock

  setup do
    freeze_time(global: true)
    :ok
  end

  describe "init" do
    test "sets min_number and timestamp" do
      start_supervised!({UserPointsServer, min_number: 10})

      state = :sys.get_state(UserPointsServer)

      assert 10 == state.min_number
      assert is_nil(state.timestamp)
    end
  end

  describe "fetch_users" do
    test "returns a list of at most two users with more points than min_number" do
      start_supervised!({UserPointsServer, min_number: 10})
      date_now = ClockMock.utc_now() |> date_to_db_format()

      user_points = 50
      user = %{points: user_points, inserted_at: date_now, updated_at: date_now}
      Repo.insert_all(User, [user, user, user])

      {:ok, result} = UserPointsServer.fetch_users()

      assert [%User{points: ^user_points}, %User{points: ^user_points}] = result.users
    end

    test "returns the previous timestamp" do
      start_supervised!({UserPointsServer, min_number: 10})

      {:ok, %{timestamp: timestamp}} = UserPointsServer.fetch_users()
      assert is_nil(timestamp)

      {:ok, %{timestamp: timestamp}} = UserPointsServer.fetch_users()
      assert timestamp == ClockMock.utc_now() |> date_to_db_format()
    end

    @tag capture_log: true
    test "returns error when task exits" do
      min_number = "force-exit-not-a-number"
      start_supervised!({UserPointsServer, min_number: min_number})

      assert {:error, "Unable to fetch users"} == UserPointsServer.fetch_users()
    end
  end

  describe "handle_info - :update" do
    test "regenerates users points and timestamps" do
      start_supervised!(UserPointsServer)

      yesterday = ClockMock.utc_now() |> DateTime.add(-1, :day) |> date_to_db_format()
      user = %{points: -1, inserted_at: yesterday, updated_at: yesterday}
      Repo.insert_all(User, [user, user, user])

      send(UserPointsServer, :update)
      wait_for_message_process!()

      date_now = ClockMock.utc_now() |> date_to_db_format()

      for user <- Repo.all(User) do
        assert user.points in 0..100
        assert date_now == user.inserted_at
        assert date_now == user.updated_at
      end
    end

    test "updates min_number" do
      start_supervised!({UserPointsServer, min_number: -1})

      send(UserPointsServer, :update)
      wait_for_message_process!()

      updated_min_number = Map.get(:sys.get_state(UserPointsServer), :min_number)

      refute -1 == updated_min_number
      assert updated_min_number in 0..100
    end

    test "schedules next update" do
      # speed up tests by temporarily setting update interval to 0
      switch_update_interval(50)

      points_server_pid = start_supervised!(UserPointsServer)
      :erlang.trace(points_server_pid, true, [:receive])

      send(UserPointsServer, :update)
      wait_for_message_process!()

      assert_received {:trace, ^points_server_pid, :receive, :update}
    end
  end

  defp switch_update_interval(new_interval) do
    current_update_interval = Application.get_env(:uscore, :user_points_server_update_interval)
    Application.put_env(:uscore, :user_points_server_update_interval, new_interval)

    on_exit(fn ->
      Application.put_env(:uscore, :user_points_server_update_interval, current_update_interval)
    end)
  end

  # Ensure async processes that update the db finish before proceeding
  defp wait_for_message_process! do
    points_server_pid = Process.whereis(UserPointsServer)
    :erlang.trace(points_server_pid, true, [:receive])
    assert_receive {:trace, ^points_server_pid, :receive, {_ref, {:updated, _}}}, 500
  end
end
