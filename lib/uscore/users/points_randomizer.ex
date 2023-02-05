defmodule UScore.Users.PointsRandomizer do
  @points_range 0..100
  @uniq_points_count Enum.count(@points_range)

  @doc """
  Generates a random points number ranging from 0 to 100. Erlang's :rand.uniform/1
  generates numbers starting from 1 so we shift randomization up by 1 and then
  shift down by 1 to ensure we cover all the numbers between 0 and 100.
  """
  @spec generate :: non_neg_integer()
  def generate, do: Enum.random(@points_range)

  @spec uniq_points_count :: non_neg_integer()
  def uniq_points_count, do: @uniq_points_count
end
