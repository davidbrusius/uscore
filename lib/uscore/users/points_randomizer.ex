defmodule UScore.Users.PointsRandomizer do
  @points_range 0..100
  @uniq_points_count Enum.count(@points_range)

  @type points :: 0..100

  @doc """
  Generates a random points number ranging from 0 to 100.
  """
  @spec generate :: points
  def generate, do: Enum.random(@points_range)

  @spec uniq_points_count :: non_neg_integer()
  def uniq_points_count, do: @uniq_points_count
end
