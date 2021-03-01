defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Yearly do
  alias HealthBoard.Contexts.Consolidations.YearlyLocationsConsolidations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, _filters, opts \\ []) do
    with {:ok, group} <- Consolidations.fetch_group(data, params, opts),
         {:ok, year} <- Consolidations.fetch_year(data, params, "year", opts),
         {:ok, location_id} <- Consolidations.fetch_location_id(data, params, opts),
         {:ok, consolidation} <- do_get([consolidation_group_id: group, year: year, location_id: location_id], opts) do
      Map.put(data, field, consolidation)
    else
      _ -> data
    end
  end

  defp do_get(manager_params, opts) do
    case ElementsData.apply_and_cache(YearlyLocationsConsolidations, :get_by, [manager_params], opts) do
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
    |> maybe_append(Consolidations.fetch_years(data, params, opts))
    |> maybe_append(Consolidations.fetch_locations_ids(data, params, opts))
    |> case do
      [] -> :error
      manager_params -> {:ok, do_list([{:consolidation_group_id, group} | manager_params], opts)}
    end
  end

  defp do_list(manager_params, opts) do
    opts = Keyword.put(opts, :default, [])
    ElementsData.apply_and_cache(YearlyLocationsConsolidations, :list_by, [manager_params], opts)
  end

  defp maybe_append(list, {:ok, item}) when is_list(item), do: item ++ list
  defp maybe_append(list, _result), do: list
end
