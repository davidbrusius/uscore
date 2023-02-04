defmodule UScore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      UScore.Repo,
      # Start the User Points Server
      UScore.Users.UserPointsServer,
      # Start the Telemetry supervisor
      UScoreWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UScore.PubSub},
      {Task.Supervisor, name: UScore.TaskSupervisor},
      # Start the Endpoint (http/https)
      UScoreWeb.Endpoint
      # Start a worker by calling: UScore.Worker.start_link(arg)
      # {UScore.Worker, arg}
    ]

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
end
