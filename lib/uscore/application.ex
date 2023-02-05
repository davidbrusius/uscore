defmodule UScore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        UScore.Repo,
        UScoreWeb.Telemetry,
        {Phoenix.PubSub, name: UScore.PubSub},
        {Task.Supervisor, name: UScore.TaskSupervisor}
      ] ++ servers(env: Mix.env()) ++ [UScoreWeb.Endpoint]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UScore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UScoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp servers(env: :test), do: []

  defp servers(env: _), do: [UScore.Users.UserPointsServer]
end
