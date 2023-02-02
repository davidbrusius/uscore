defmodule UScore.Repo do
  use Ecto.Repo,
    otp_app: :uscore,
    adapter: Ecto.Adapters.Postgres
end
