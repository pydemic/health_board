defmodule HealthBoardWeb.DashboardLive.ElementsData.Utils do
  @spec delete(map, atom, map, map, keyword) :: map
  def delete(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} -> Map.delete(data, String.to_atom(what))
      :error -> data
    end
  end

  @spec drop(map, atom, map, map, keyword) :: map
  def drop(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} ->
        keys =
          what
          |> String.split(",")
          |> Enum.map(&String.to_atom/1)

        Map.drop(data, keys)

      :error ->
        data
    end
  end

  @spec from_values_to_total(map, atom, map, map, keyword) :: map
  def from_values_to_total(data, _field, params, _filters, _opts \\ []) do
    with %{"what" => what, "index" => index} <- params,
         what <- String.to_atom(what),
         {:ok, %{values: values} = map} <- Map.fetch(data, what) do
      Map.put(data, what, Map.put(map, :total, extract_value_from_values(values, index)))
    else
      _result -> data
    end
  end

  defp extract_value_from_values(values, index) do
    index = String.to_integer(index)

    case values do
      nil ->
        0

      string when is_binary(string) ->
        string
        |> String.split(",")
        |> Enum.at(index, "0")
        |> String.to_integer()

      list when is_list(list) ->
        Enum.at(list, index, 0)

      _values ->
        0
    end
  rescue
    _error -> 0
  end

  @spec take(map, atom, map, map, keyword) :: map
  def take(data, _field, params, _filters, _opts \\ []) do
    case Map.fetch(params, "what") do
      {:ok, what} ->
        keys =
          what
          |> String.split(",")
          |> Enum.map(&String.to_atom/1)

        Map.take(data, keys)

      :error ->
        data
    end
  end
end
