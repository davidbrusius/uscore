defmodule UScoreWeb.UsersView do
  use UScoreWeb, :view

  def render("index.json", assigns) do
    %{
      users: Enum.map(assigns[:users], &Map.take(&1, [:id, :points])),
      timestamp: if(assigns[:timestamp], do: to_string(assigns[:timestamp]))
    }
  end
end
