defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.All do
  alias HealthBoard.Contexts.Consolidations.LocationsConsolidations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, _filters, opts \\ []) do
    with {:ok, group} <- Consolidations.fetch_group(data, params, opts),
         {:ok, location_id} <- Consolidations.fetch_location_id(data, params, opts),
         {:ok, consolidation} <- do_get(params, group, location_id, opts) do
      Map.put(data, field, consolidation)
    else
      _ -> data
    end
  end

  defp do_get(params, group, location_id, opts) do
    manager_params = maybe_preload(params, consolidation_group_id: group, location_id: location_id)

    case ElementsData.apply_and_cache(LocationsConsolidations, :get_by, [manager_params], opts) do
      nil -> :error
      consolidation -> {:ok, consolidation}
    end
  end

  @spec list(map, atom, map, map, keyword) :: map
  def list(data, field, params, _filters, opts \\ []) do
    case Consolidations.fetch_group(data, params, opts) do
      {:ok, group} ->
        Map.put(
          data,
          field,
          do_list(
            params,
            maybe_append([consolidation_group_id: group], Consolidations.fetch_locations_ids(data, params, opts)),
            opts
          )
        )

      _ ->
        data
    end
  end

  defp do_list(params, manager_params, opts) do
    manager_params = maybe_preload(params, manager_params)
    opts = Keyword.put(opts, :default, [])
    ElementsData.apply_and_cache(LocationsConsolidations, :list_by, [manager_params], opts)
  end

  defp maybe_preload(params, manager_params) do
    case Map.fetch(params, "preload") do
      {:ok, "location"} -> [{:preload, :location} | manager_params]
      _result -> manager_params
    end
  end

  defp maybe_append(list, {:ok, item}) when is_list(item), do: item ++ list
  defp maybe_append(list, _result), do: list
end
