defmodule UScore.UsersControllerTest do
  use UScoreWeb.ConnCase, async: false
  alias UScore.Repo
  alias UScore.Users.{User, UserPointsServer}

  describe "index" do
    setup do
      freeze_time(global: true)
      date_now = DateTime.utc_now() |> date_to_db_format()
      {:ok, conn: build_conn(), date_now: date_now}
    end

    test "returns users with points greater than min_number and timestamp", %{
      conn: conn,
      date_now: date_now
    } do
      start_supervised!({UserPointsServer, min_number: 30})

      Repo.insert_all(User, [
        %{points: 10, inserted_at: date_now, updated_at: date_now},
        %{points: 50, inserted_at: date_now, updated_at: date_now},
        %{points: 100, inserted_at: date_now, updated_at: date_now}
      ])

      conn = get(conn, Routes.users_path(conn, :index))

      assert %{
               "users" => [%{"id" => _, "points" => 50}, %{"id" => _, "points" => 100}],
               "timestamp" => nil
             } = json_response(conn, 200)
    end

    test "returns current timestamp for subsequent call", %{conn: conn, date_now: date_now} do
      start_supervised!(UserPointsServer)

      conn = get(conn, Routes.users_path(conn, :index))
      assert %{"timestamp" => nil} = json_response(conn, 200)

      conn = get(conn, Routes.users_path(conn, :index))
      date_now = to_string(date_now)
      assert %{"timestamp" => ^date_now} = json_response(conn, 200)
    end

    @tag capture_log: true
    test "returns 500 - internal_server_error when user fetching fails", %{conn: conn} do
      min_number = "force-exit-not-a-number"
      start_supervised!({UserPointsServer, min_number: min_number})

      conn = get(conn, Routes.users_path(conn, :index))
      assert %{"error" => "Unable to fetch users"} == json_response(conn, 500)
    end
  end
end
