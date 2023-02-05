defmodule UScore.Clock.Real do
  @behaviour UScore.Clock

  @impl true
  def utc_now, do: DateTime.utc_now()
end
