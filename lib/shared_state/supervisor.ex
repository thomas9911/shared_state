defmodule SharedState.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    tree = Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    add_queues()
    tree
  end

  @impl true
  def init(_init_arg) do
    children = [
      SharedState.State,
      {Registry, keys: :unique, name: SharedState.Register, meta: [keys: MapSet.new()]},
      {Task.Supervisor, name: SharedState.TaskSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: SharedState.StateQueueSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp add_queues() do
    processes = Application.get_env(:shared_state, :queue_processes) || 3

    Enum.each(
      0..(processes - 1),
      fn i ->
        number = String.pad_leading("#{i}", 4, "0")
        new_agent = "agent#{number}"
        name = {:via, Registry, {SharedState.Register, new_agent}}
        {:ok, set} = Registry.meta(SharedState.Register, :keys)
        set = MapSet.put(set, new_agent)
        Registry.put_meta(SharedState.Register, :keys, set)

        {:ok, _} =
          DynamicSupervisor.start_child(
            SharedState.StateQueueSupervisor,
            {SharedState.StateQueue, name: name}
          )
      end
    )
  end
end
