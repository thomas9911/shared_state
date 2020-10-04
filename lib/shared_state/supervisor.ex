defmodule SharedState.Supervisor do
  use Supervisor

  @default_processes 3

  def start_link(init_arg) do
    tree = Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)

    processes = fetch_process_config(init_arg)

    add_queues(processes)
    tree
  end

  @impl true
  def init(init_arg) do
    processes = fetch_process_config(init_arg)

    children = [
      SharedState.State,
      {Registry, keys: :unique, name: SharedState.Register, meta: [keys: MapSet.new()]},
      {Task.Supervisor, name: SharedState.TaskSupervisor},
      {DynamicSupervisor,
       strategy: :one_for_one, name: SharedState.QueueSupervisor, max_restarts: processes * 2}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp add_queues(processes) do
    Enum.each(
      0..(processes - 1),
      fn i ->
        number = String.pad_leading("#{i}", 4, "0")
        new_queue = "queue#{number}"
        name = {:via, Registry, {SharedState.Register, new_queue}}
        {:ok, set} = Registry.meta(SharedState.Register, :keys)
        set = MapSet.put(set, new_queue)
        Registry.put_meta(SharedState.Register, :keys, set)

        {:ok, _} =
          DynamicSupervisor.start_child(
            SharedState.QueueSupervisor,
            {SharedState.Queue, name: name}
          )
      end
    )
  end

  defp fetch_process_config(list) do
    Keyword.get(list, :queue_processes) || Application.get_env(:shared_state, :queue_processes) ||
      @default_processes
  end
end
