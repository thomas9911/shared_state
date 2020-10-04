defmodule SharedState.Queue.Flush do
  @moduledoc """
  Handles flush logic
  """

  def prepare(actions, command) do
    case command do
      :all -> {actions, []}
      {:lifo, amount} -> lifo(actions, amount)
      {:fifo, amount} -> fifo(actions, amount)
    end
  end

  def fifo(actions, amount) do
    {actions, to_flush} = Enum.split(actions, length(actions) - amount)
    {to_flush, actions}
  end

  def lifo(actions, amount) do
    {to_flush, actions} = Enum.split(actions, amount)
    {to_flush, actions}
  end
end
