defmodule UScoreWeb.Router do
  use UScoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UScoreWeb do
    pipe_through :api

    get "/", UsersController, :index
  end
end
