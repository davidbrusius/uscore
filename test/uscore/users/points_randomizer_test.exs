defmodule UScore.Users.PointsRandomizerTest do
  use ExUnit.Case, async: true
  alias UScore.Users.PointsRandomizer

  describe "generate/0" do
    test "returns a number between 0 and 100" do
      random_points = PointsRandomizer.generate()

      assert random_points in 0..100
    end

    test "returns 0 as random_points" do
      :rand.seed(:exsplus, 266)

      assert 0 == PointsRandomizer.generate()
    end

    test "returns 100 as random_points" do
      :rand.seed(:exsplus, 14)

      assert 100 == PointsRandomizer.generate()
    end
  end

  describe "uniq_points_count/0" do
    test "returns the count of possible uniq points" do
      assert 101 == PointsRandomizer.uniq_points_count()
    end
  end
end
