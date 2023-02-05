defmodule UScoreWeb.UsersController do
  use UScoreWeb, :controller
  alias UScore.Users.UserPointsServer

  def index(conn, _params) do
    case UserPointsServer.fetch_users() do
      {:ok, result} ->
        conn
        |> put_status(:ok)
        |> render("index.json", result)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: reason})
    end
  end
end
