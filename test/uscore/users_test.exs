defmodule UScore.UsersTest do
  use UScore.DataCase, async: false
  alias UScore.Users
  alias UScore.Users.User
  alias UScore.Clock.Mock, as: ClockMock

  setup do
    freeze_time()
    :ok
  end

  describe "fetch_users/1" do
    test "fetches users with points greater than min_number" do
      date_now = ClockMock.utc_now() |> date_to_db_format()

      Repo.insert_all(User, [
        %{points: 0, inserted_at: date_now, updated_at: date_now},
        %{points: 50, inserted_at: date_now, updated_at: date_now},
        %{points: 100, inserted_at: date_now, updated_at: date_now}
      ])

      min_number = 10
      users = Users.fetch_users(min_number)

      assert [%User{points: 50}, %User{points: 100}] = users
    end

    test "returns at most two users" do
      date_now = ClockMock.utc_now() |> date_to_db_format()

      Repo.insert_all(User, [
        %{points: 50, inserted_at: date_now, updated_at: date_now},
        %{points: 75, inserted_at: date_now, updated_at: date_now},
        %{points: 100, inserted_at: date_now, updated_at: date_now}
      ])

      min_number = 10
      users = Users.fetch_users(min_number)

      assert [%User{points: 50}, %User{points: 75}] = users
    end

    test "returns single user" do
      date_now = ClockMock.utc_now() |> date_to_db_format()

      Repo.insert_all(User, [
        %{points: 0, inserted_at: date_now, updated_at: date_now},
        %{points: 50, inserted_at: date_now, updated_at: date_now}
      ])

      min_number = 10
      users = Users.fetch_users(min_number)

      assert [%User{points: 50}] = users
    end

    test "returns no users when points are lower than min_number" do
      date_now = ClockMock.utc_now() |> date_to_db_format()

      Repo.insert_all(User, [
        %{points: 0, inserted_at: date_now, updated_at: date_now},
        %{points: 5, inserted_at: date_now, updated_at: date_now}
      ])

      min_number = 10
      users = Users.fetch_users(min_number)

      assert [] == users
    end
  end

  describe "regenerate_points/0" do
    test "regenerates all users points randomly" do
      date_now = ClockMock.utc_now() |> date_to_db_format()
      user = %{points: 0, inserted_at: date_now, updated_at: date_now}
      Repo.insert_all(User, [user, user, user])
      Repo.query!("SELECT setseed(1);")

      Users.regenerate_points()

      [user1, user2, user3] = Repo.all(User)

      assert 40 == user1.points
      assert 75 == user2.points
      assert 39 == user3.points
    end

    test "updates users timestamps" do
      yesterday = ClockMock.utc_now() |> DateTime.add(-1, :day) |> date_to_db_format()

      user = %{points: 0, inserted_at: yesterday, updated_at: yesterday}
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
