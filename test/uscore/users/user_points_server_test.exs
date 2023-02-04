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
      state = :sys.get_state(UserPointsServer)

      assert state.min_number in 0..100
      assert is_nil(state.timestamp)
    end
  end

  describe "handle_info - :update" do
    test "regenerates users points and timestamps" do
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
      :sys.replace_state(UserPointsServer, fn state ->
        %{state | min_number: -1}
      end)

      send(UserPointsServer, :update)
      wait_for_message_process!()

      updated_min_number = Map.get(:sys.get_state(UserPointsServer), :min_number)

      refute -1 == updated_min_number
      assert updated_min_number in 0..100
    end

    test "schedules next update" do
      # speed up tests by temporarily setting update interval to 0
      switch_update_interval(50)

      points_server_pid = Process.whereis(UserPointsServer)
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
