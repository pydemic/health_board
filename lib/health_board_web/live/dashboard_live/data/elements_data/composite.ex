defmodule HealthBoardWeb.DashboardLive.ElementsData.Composite do
  @spec average(map, atom, map, map, keyword) :: map
  def average(data, field, params, _filters, _opts \\ []) do
    with %{"from" => from, "group_by" => group_by, "average_by" => average_by} <- params,
         {:ok, list} when is_list(list) <- Map.fetch(data, String.to_atom(from)) do
      group_by_field = String.to_atom(group_by)
      average_by_field = String.to_atom(average_by)

      value =
        list
        |> Enum.group_by(&Map.get(&1, group_by_field))
        |> Enum.map(&append_in_group(&1, average_by_field))
        |> Enum.map(&average_in_field(&1, average_by_field))

      Map.put(data, field, value)
    else
      _result -> data
    end
  end

  defp append_in_group({_key, list}, field) do
    Enum.reduce(list, fn m1, m2 ->
      case Map.fetch(m1, field) do
        {:ok, value} ->
          Map.update(m2, field, {1, [value]}, fn
            {length, values} -> {length + 1, [value | values]}
            value2 -> {2, [value, value2]}
          end)

        _error ->
          m2
      end
    end)
  end

  defp average_in_field(map, field) do
    case Map.fetch(map, field) do
      {:ok, {length, values}} when is_list(values) -> Map.put(map, field, div(Enum.sum(values), length))
      {:ok, values} when is_list(values) -> Map.put(map, field, div(Enum.sum(values), length(values)))
      _result -> map
    end
  end

  @spec filter(map, atom, map, map, keyword) :: map
  def filter(data, field, params, _filters, _opts \\ []) do
    with %{"from" => from, "where" => where} <- params,
         {:ok, list} when is_list(list) <- Map.fetch(data, String.to_atom(from)),
         {:ok, filtered_list} <- filter_list(data, list, where),
         {:ok, value} <- maybe_get(filtered_list, params["get"]) do
      Map.put(data, field, value)
    else
      _result -> data
    end
  end

  defp filter_list(data, list, where) do
    case String.split(where, "__") do
      [field, "in", values] -> filter_in(data, list, field, values)
      [field, "gt", value] -> filter_gt(list, field, value)
      [field, "lt", value] -> filter_lt(list, field, value)
      _result -> :error
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

  defp filter_lt(list, field, value) do
    field = String.to_atom(field)
    value = String.to_integer(value)
    {:ok, Enum.filter(list, &(Map.get(&1, field) <= value))}
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

  @spec from(map, atom, map, map, keyword) :: map
  def from(data, field, params, _filters, _opts \\ []) do
    with %{"what" => what, "get" => get} <- params,
         {:ok, map} <- Map.fetch(data, String.to_atom(what)),
         {:ok, value} <- Map.fetch(map, String.to_atom(get)) do
      Map.put(data, field, value)
    else
      _result -> data
    end
  end

  @spec replace(map, atom, map, map, keyword) :: map
  def replace(data, field, params, _filters, _opts \\ []) do
    with %{"what" => what} <- params,
         what <- String.to_atom(what),
         {:ok, value} <- Map.fetch(data, what) do
      data
      |> Map.delete(what)
      |> Map.put(field, value)
    else
      _result -> data
    end
  end
end
