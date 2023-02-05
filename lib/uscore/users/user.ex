defmodule UScore.Users.User do
  use Ecto.Schema
  alias UScore.Users.PointsRandomizer

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          points: PointsRandomizer.points(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "users" do
    field :points, :integer

    timestamps()
  end
end
