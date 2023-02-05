defmodule UScore.Users.UserPointsServer do
  use GenServer
  alias UScore.Users
  alias UScore.Users.PointsRandomizer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  @impl true
  def init(_) do
    schedule_work()
    {:ok, %{min_number: PointsRandomizer.generate(), timestamp: nil}}
  end

  @impl true
  def handle_info(:update, state) do
    Task.Supervisor.async_nolink(UScore.TaskSupervisor, fn ->
      Users.regenerate_points()
      {:updated, %{state | min_number: PointsRandomizer.generate()}}
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({_ref, {:updated, new_state}}, _old_state) do
    schedule_work()
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, _, :normal}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, _, _error}, state) do
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    update_interval = Application.get_env(:uscore, :user_points_server_update_interval)
    Process.send_after(self(), :update, update_interval)
  end
end
