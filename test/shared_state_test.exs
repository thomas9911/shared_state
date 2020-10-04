defmodule SharedStateTest do
  use ExUnit.Case
  doctest SharedState

  alias SharedState.{StateQueue, State}

  defp quick_sleep() do
    # wait a bit before claiming the state
    Process.sleep(5)
  end

  describe "works" do
    setup do
      StateQueue.clear_all()
      State.init()
    end

    test "update" do
      assert :ok == SharedState.update(fn state -> Map.put(state, :a, 1) end)
      
      quick_sleep()

      assert %{a: 1} == State.state()
    end

    test "update lazy" do
      assert :ok == SharedState.update_lazy(fn state -> Map.put(state, :a, 1) end)
    
      quick_sleep()

      assert %{} == State.state()
    end

    test "get" do
      assert :ok == SharedState.update(fn state -> Map.put(state, :a, 1) end)

      assert 1 == SharedState.get(& &1.a)
    end
  end

  describe "not works" do
    setup do
      StateQueue.clear_all()
      State.init()
    end
  end
end
