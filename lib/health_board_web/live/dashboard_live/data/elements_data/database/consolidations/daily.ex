defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Daily do
  alias HealthBoard.Contexts.Consolidations.DailyLocationsConsolidations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, _filters, opts \\ []) do
    with {:ok, group} <- Consolidations.fetch_group(data, params, opts),
         {:ok, date} <- Consolidations.fetch_date(data, params, "date", opts),
         {:ok, location_id} <- Consolidations.fetch_location_id(data, params, opts),
         {:ok, consolidation} <- do_get(params, group, date, location_id, opts) do
      Map.put(data, field, consolidation)
    else
      _ -> data
    end
  end

  defp do_get(params, group, date, location_id, opts) do
    manager_params = maybe_preload(params, consolidation_group_id: group, date: date, location_id: location_id)

    case ElementsData.apply_and_cache(DailyLocationsConsolidations, :get_by, [manager_params], opts) do
      nil -> :error
      consolidation -> {:ok, consolidation}
    end
  end

  @spec list(map, atom, map, map, keyword) :: map
  def list(data, field, params, _filters, opts \\ []) do
    with {:ok, group} <- Consolidations.fetch_group(data, params, opts),
         {:ok, consolidations} <- list_consolidations(data, params, group, opts) do
      Map.put(data, field, consolidations)
    else
      _ -> data
    end
  end

  defp list_consolidations(data, params, group, opts) do
    []
    |> maybe_append(Consolidations.fetch_dates(data, params, opts))
    |> maybe_append(Consolidations.fetch_locations_ids(data, params, opts))
    |> case do
      [] -> :error
      manager_params -> {:ok, do_list(params, [{:consolidation_group_id, group} | manager_params], opts)}
    end
  end

  defp do_list(params, manager_params, opts) do
    manager_params = maybe_preload(params, manager_params)
    opts = Keyword.put(opts, :default, [])
    ElementsData.apply_and_cache(DailyLocationsConsolidations, :list_by, [manager_params], opts)
  end

  defp maybe_preload(params, manager_params) do
    case Map.fetch(params, "preload") do
      {:ok, "location"} -> [{:preload, :location} | manager_params]
      {:ok, "location_and_state"} -> [{:preload, :location_and_state} | manager_params]
      _result -> manager_params
    end
  end

  defp maybe_append(list, {:ok, item}) when is_list(item), do: item ++ list
  defp maybe_append(list, _result), do: list
end
