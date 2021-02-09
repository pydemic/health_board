defmodule HealthBoardWeb.DashboardLive.ElementsData.Composite do
  @spec filter(map, atom, map, map) :: map
  def filter(data, field, params, _filters) do
    with %{"from" => from, "where" => where} <- params,
         {:ok, list} when is_list(list) <- Map.fetch(data, String.to_atom(from)),
         {:ok, filtered_list} <- filter_list(data, list, where),
         {:ok, value} <- maybe_get(filtered_list, params["get"]) do
      Map.put(data, field, value)
    else
      _ -> data
    end
  end

  defp filter_list(data, list, where) do
    case String.split(where, "__") do
      [field, "in", values] -> filter_in(data, list, field, values)
      [field, "gt", value] -> filter_gt(list, field, value)
      _ -> :error
    end
  end

  defp filter_in(data, list, field, values) do
    field = String.to_atom(field)

    case Map.fetch(data, String.to_atom(values)) do
      {:ok, values} -> {:ok, Enum.filter(list, &(Map.get(&1, field) in values))}
      :error -> :error
    end
  rescue
    _error -> :error
  end

  defp filter_gt(list, field, value) do
    field = String.to_atom(field)
    value = String.to_integer(value)
    {:ok, Enum.filter(list, &(Map.get(&1, field) >= value))}
  rescue
    _error -> :error
  end

  defp maybe_get(list, field) do
    if not is_nil(field) and is_list(list) do
      field = String.to_atom(field)
      {:ok, Enum.map(list, &Map.get(&1, field))}
    else
      {:ok, list}
    end
  end

  @spec from(map, atom, map, map) :: map
  def from(data, field, params, _filters) do
    with %{"what" => what, "get" => get} <- params,
         {:ok, map} <- Map.fetch(data, String.to_atom(what)),
         {:ok, value} <- Map.fetch(map, String.to_atom(get)) do
      Map.put(data, field, value)
    else
      _ -> data
    end
  end
end
