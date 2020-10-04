defmodule SharedState.Error do
  def format(map) when is_map(map) do
    statuses = Enum.map(map, &elem(&1, 1))

    if Enum.all?(statuses, &(&1 == :ok)) do
      :ok
    else
      error_list =
        statuses
        |> Enum.reject(&(&1 == :ok))
        |> Enum.flat_map(&extract_error/1)

      {:error, error_list}
    end
  end

  defp extract_error(:error), do: []
  defp extract_error({:error, error}), do: List.wrap(error)
end
