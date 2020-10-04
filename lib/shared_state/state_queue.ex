defmodule SharedState.StateQueue do
  use GenServer

  @timeout 5000

  def start_link(opts) do
    {initial_value, opts} = Keyword.pop(opts, :initial_value, [])
    # Agent.start_link(fn -> initial_value end, opts)
    GenServer.start_link(__MODULE__, initial_value, opts)
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  # client

  @doc """
  Push element on the queue. 
  elem should be a function with one argument which is the state and should return the new state. 

  for example:

  ```elixir
  def update_map(state) do
    state
    |> Map.put_new(:test, 0)
    |> Map.update!(:test, &(&1 + 1))
  end
  ```

  """
  def push(elem) when is_function(elem, 1) do
    GenServer.cast(random_module(), {:push, elem})
  end

  @doc """
  get the state of a random queue.
  """
  def state() do
    GenServer.call(random_module(), :state, @timeout)
  end

  @doc """
  get all the states of all the queues, returns all the states per process in a map.
  """
  def all_states() do
    Map.new(all_modules(), &{&1, GenServer.call(&1, :state)})
  end

  @doc """
  clear a random queue, returns the status.
  """
  def clear() do
    GenServer.cast(random_module(), :clear)
  end

  @doc """
  clear all queues, returns all the statuses per process in a map.
  """
  def clear_all() do
    Map.new(all_modules(), &{&1, GenServer.cast(&1, :clear)})
  end

  @doc """
  Flush all elements for single random queue.
  """
  def flush() do
    GenServer.cast(random_module(), :flush)
  end

  @doc """
  Flush all elements for all queues.
  """
  def flush_all() do
    Map.new(all_modules(), &{&1, GenServer.cast(&1, :flush)})
  end

  @doc """
  Flush amount of elements for all queues.
  This so you can split up the amount of jobs into reasonable chucks.

  order can be one of [:fifo, :lifo], defaults to :fifo

  fifo: first in first out, the first element added gets evaluated first
  lifo: last in first out, the last element added gets evaluated first
  """
  def flush_all_amount(amount, order \\ :fifo) do
    Map.new(all_modules(), &{&1, GenServer.cast(&1, {:flush, order, amount})})
  end

  # server

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  def handle_cast(:flush, state) do
    Enum.map(state, &SharedState.State.update/1)
    {:noreply, []}
  end

  def handle_cast({:flush, :fifo, amount}, state) do
    {state, to_flush} = Enum.split(state, length(state) - amount)
    Enum.map(to_flush, &SharedState.State.update/1)
    {:noreply, state}
  end

  def handle_cast({:flush, :lifo, amount}, state) do
    {to_flush, state} = Enum.split(state, amount)
    Enum.map(to_flush, &SharedState.State.update/1)
    {:noreply, state}
  end

  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # module stuff

  def random_module() do
    # {:ok, set} = Registry.meta(Registry.ViaTest, :keys)
    # agent_name = set |> Enum.take_random(1) |> Enum.at(0)
    # {:via, Registry, {Registry.ViaTest, agent_name}}
    case all_modules()
         |> Enum.take_random(1)
         |> Enum.at(0) do
      nil -> random_module()
      pid -> pid
    end
  end

  def all_modules() do
    SharedState.StateQueueSupervisor
    |> DynamicSupervisor.which_children()
    |> Enum.filter(&is_valid_worker/1)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  defp is_valid_worker({_, pid, :worker, [__MODULE__]}) when is_pid(pid), do: true
  defp is_valid_worker(_), do: false
end

# {:ok, _} = Registry.start_link(keys: :unique, name: Registry.ViaTest,  meta: [keys: MapSet.new()])
# # Registry.put_meta(Registry.ViaTest, :keys, MapSet.new())

# new_agent = "agent001"
# name = {:via, Registry, {Registry.ViaTest, new_agent}}
# {:ok, set} = Registry.meta(Registry.ViaTest, :keys)
# set = MapSet.put(set, new_agent)
# Registry.put_meta(Registry.ViaTest, :keys, set)
# {:ok, _} = Agent.start_link(fn -> 0 end, name: name)

# new_agent = "agent002"
# name = {:via, Registry, {Registry.ViaTest, new_agent}}
# {:ok, set} = Registry.meta(Registry.ViaTest, :keys)
# set = MapSet.put(set, new_agent)
# Registry.put_meta(Registry.ViaTest, :keys, set)
# {:ok, _} = Agent.start_link(fn -> 0 end, name: name)

# # {:ok, _} = Agent.start_link(fn -> 0 end, name: name)
# # {:ok, _} = Agent.start_link(fn -> 0 end, name: name2)
# # Agent.get(name, & &1)
# {:ok, set} = Registry.meta(Registry.ViaTest, :keys)
# agent_name = set |> Enum.take_random(1) |> Enum.at(0)
# name = {:via, Registry, {Registry.ViaTest, agent_name}}
# Agent.get(name, & &1)

# # Registry.match(Registry.ViaTest)
