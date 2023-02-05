defmodule UScore.Users.UserPointsServer do
  use GenServer
  require Logger
  alias UScore.Users
  alias UScore.Users.PointsRandomizer

  @name __MODULE__
  @clock Application.compile_env!(:uscore, :clock)

  @type timestamp :: DateTime.t()

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @impl true
  def init(opts) do
    min_number = Keyword.get(opts, :min_number, PointsRandomizer.generate())
    schedule_work()
    {:ok, %{min_number: min_number, timestamp: nil}}
  end

  @spec fetch_users() :: {:ok, map()} | {:error, binary()}
  def fetch_users do
    result = GenServer.call(@name, :fetch_users)
    {:ok, result}
  catch
    :exit, _ -> {:error, "Unable to fetch users"}
  end

  @impl true
  def handle_call(:fetch_users, from, state) do
    Task.async(fn ->
      users = Users.fetch_users(state.min_number)
      GenServer.reply(from, %{users: users, timestamp: state.timestamp})
    end)

    {:noreply, %{state | timestamp: current_date_time()}}
  end

  defp current_date_time do
    @clock.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
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

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp schedule_work do
    update_interval = Application.get_env(:uscore, :user_points_server_update_interval)
    Process.send_after(self(), :update, update_interval)
  end
end
