defmodule UScore.DateTimeHelpers do
  def freeze_time(global: true) do
    Mox.set_mox_global()
    freeze_time()
  end

  def freeze_time do
    time_now = DateTime.utc_now()
    Mox.stub(UScore.Clock.Mock, :utc_now, fn -> time_now end)
  end

  def date_to_db_format(date) do
    date
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end
end
