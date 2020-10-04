defmodule SharedState do
  @moduledoc """
  Documentation for `SharedState`.

  To get started add `SharedState.Supervisor` to your supervisor tree.

  ```
    children = [
      SharedState.Supervisor
    ]
  ```
  The default of processes for the queue is 3. You can set this by passing :queue_processes in the supervisor tree.

  ```
    children = [
      {SharedState.Supervisor, queue_processes: 5}
    ]
  ```

  or adding it in you config under:

  ```
    config :shared_state, queue_processes: 8
  ```

  It is ofcourse possible to create a schedule that flushes the queue after a period of time.
  take a look at: https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages
  And use the function `SharedState.Queue.flush_all/0` to flush all the updates to the main state.
  """

  alias SharedState.{State, Queue, Error}

  def update(func) when is_function(func, 1) do
    case Queue.push(func) do
      :ok -> Queue.flush_all() |> Error.format()
      e -> e
    end
  end

  def update_lazy(func) when is_function(func, 1) do
    Queue.push(func)
  end

  def get(func) when is_function(func, 1) do
    case Queue.flush_all(true) |> Error.format() do
      :ok -> State.get(func)
      e -> e
    end
  end

  def get_no_flush(func) when is_function(func, 1) do
    State.get(func)
  end
end
