defmodule SharedState.State do
  use Agent

  @timeout 5000

  def start_link(opts) do
    {initial_value, opts} = Keyword.pop(opts, :initial_value, %{})
    opts = Keyword.put_new(opts, :name, __MODULE__)
    Agent.start_link(fn -> initial_value end, opts)
  end

  def init(init \\ %{}) when is_map(init) do
    Agent.update(__MODULE__, fn _ -> init end)
  end

  def state do
    Agent.get(__MODULE__, & &1)
  end

  def cast(func) do
    Agent.cast(__MODULE__, func)
  end

  def cast(module, fun, args) do
    Agent.cast(__MODULE__, module, fun, args)
  end

  def get(func, timeout \\ @timeout) when is_integer(timeout) do
    Agent.get(__MODULE__, func, timeout)
  end

  def get(module, fun, args, timeout \\ @timeout) when is_integer(timeout) do
    Agent.get(__MODULE__, module, fun, args, timeout)
  end

  def get_and_update(func, timeout \\ @timeout) when is_integer(timeout) do
    Agent.get_and_update(__MODULE__, func, timeout)
  end

  def get_and_update(module, fun, args, timeout \\ @timeout) when is_integer(timeout) do
    Agent.get_and_update(__MODULE__, module, fun, args, timeout)
  end

  def update(func, timeout \\ @timeout) when is_integer(timeout) do
    Agent.update(__MODULE__, func, timeout)
  end

  def update(module, fun, args, timeout \\ @timeout) when is_integer(timeout) do
    Agent.update(__MODULE__, module, fun, args, timeout)
  end
end
