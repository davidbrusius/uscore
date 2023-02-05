defmodule UScore.Repo.Migrations.EnsurePointsWithinRange do
  use Ecto.Migration

  def change do
    create constraint("users", :points_must_be_within_range,
             check: "points >= 0 AND points <= 100"
           )
  end
end
