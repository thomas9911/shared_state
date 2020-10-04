defmodule SharedState.ErrorTest do
  use ExUnit.Case

  alias SharedState.Error

  describe "format map" do
    test "ok" do
      map = %{
        1 => :ok,
        2 => :ok,
        3 => :ok
      }

      assert :ok == Error.format(map)
    end

    test "error atom" do
      map = %{
        1 => :error,
        2 => :ok,
        3 => :ok
      }

      assert {:error, []} == Error.format(map)
    end

    test "error tuple" do
      map = %{
        1 => {:error, :some_error},
        2 => :ok,
        3 => {:error, :another_error}
      }

      assert {:error, [:some_error, :another_error]} == Error.format(map)
    end
  end
end
