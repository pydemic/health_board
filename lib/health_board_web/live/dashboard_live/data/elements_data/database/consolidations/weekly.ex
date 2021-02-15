defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Weekly do
  alias HealthBoard.Contexts.Consolidations.WeeklyLocationsConsolidations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations

  @spec list(map, atom, map, map) :: map
  def list(data, field, params, _filters) do
    with {:ok, group} <- Consolidations.fetch_group(data, params),
         {:ok, consolidations} <- list_consolidations(data, params, group) do
      Map.put(data, field, consolidations)
    else
      _ -> data
    end
  end

  defp list_consolidations(data, params, group) do
    []
    |> maybe_append(Consolidations.fetch_years(data, params))
    |> maybe_append(Consolidations.fetch_weeks(data, params))
    |> maybe_append(Consolidations.fetch_locations_ids(data, params))
    |> case do
      [] -> :error
      manager_params -> {:ok, do_list([{:consolidation_group_id, group} | manager_params])}
    end
  end

  defp do_list(manager_params) do
    ElementsData.database_data(WeeklyLocationsConsolidations, :list_by, [manager_params])
  end

  defp maybe_append(list, {:ok, item}) when is_list(item), do: item ++ list
  defp maybe_append(list, _result), do: list
end
