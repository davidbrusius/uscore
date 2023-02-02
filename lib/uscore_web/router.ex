defmodule UScoreWeb.Router do
  use UScoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UScoreWeb do
    pipe_through :api
  end
end
