defmodule SharedState.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SharedState.State,
      {Registry, keys: :unique, name: SharedState.Register, meta: [keys: MapSet.new()]},
      {Task.Supervisor, name: SharedState.TaskSupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: SharedState.StateQueueSupervisor}
    ]

    opts = [strategy: :one_for_one, name: SharedState.Supervisor]
    tree = Supervisor.start_link(children, opts)

    add_queues()

    tree
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
