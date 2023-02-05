defmodule UScore.Clock do
  @moduledoc """
  Abstract clock interactions to ensure time based tests are consistent
  """

  @callback utc_now :: DateTime.t()
end
