defmodule SharedState do
  @moduledoc """
  Documentation for `SharedState`.
  """

  alias SharedState.{State, StateQueue, Error}

  def update(func) when is_function(func, 1) do
    case StateQueue.push(func) do
      :ok -> StateQueue.flush_all() |> Error.format()
      e -> e
    end
  end

  def update_lazy(func) when is_function(func, 1) do
    StateQueue.push(func)
  end

  def get(func) when is_function(func, 1) do
    case StateQueue.flush_all() |> Error.format() do
      :ok -> State.get(func)
      e -> e
    end
  end

  def get_no_flush(func) when is_function(func, 1) do
    State.get(func)
  end
end
