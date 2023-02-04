defmodule UScore.UsersTest do
  use UScore.DataCase, async: false
  alias UScore.Users
  alias UScore.Users.User
  alias UScore.Clock.Mock, as: ClockMock

  describe "regenerate_points/0" do
    setup do
      freeze_time()
      :ok
    end

    test "regenerates all users points randomly" do
      date_now = ClockMock.utc_now() |> date_to_db_format()
      user = %{points: -1, inserted_at: date_now, updated_at: date_now}
      Repo.insert_all(User, [user, user, user])

      Users.regenerate_points()

      for user <- Repo.all(User) do
        assert user.points in 0..100
      end
    end

    test "updates users timestamps" do
      yesterday = ClockMock.utc_now() |> DateTime.add(-1, :day) |> date_to_db_format()

      user = %{points: -1, inserted_at: yesterday, updated_at: yesterday}
      Repo.insert_all(User, [user, user, user])

      Users.regenerate_points()

      date_now = ClockMock.utc_now() |> date_to_db_format()

      for user <- Repo.all(User) do
        assert date_now == user.inserted_at
        assert date_now == user.updated_at
      end
    end
  end
end
