defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Monthly do
  alias HealthBoard.Contexts.Consolidations.MonthlyLocationsConsolidations
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
    {
      Consolidations.fetch_years(data, params),
      Consolidations.fetch_months(data, params),
      Consolidations.fetch_locations_ids(data, params)
    }
    |> case do
      {:error, :error, :error} -> :error
      {:error, :error, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ lk)}
      {:error, {:ok, mk}, :error} -> {:ok, do_list([consolidation_group_id: group] ++ mk)}
      {:error, {:ok, mk}, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ mk ++ lk)}
      {{:ok, yk}, :error, :error} -> {:ok, do_list([consolidation_group_id: group] ++ yk)}
      {{:ok, yk}, :error, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ lk)}
      {{:ok, yk}, {:ok, mk}, :error} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ mk)}
      {{:ok, yk}, {:ok, mk}, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ mk ++ lk)}
    end
  end

  defp do_list(manager_params) do
    ElementsData.database_data(MonthlyLocationsConsolidations, :list_by, [manager_params])
  end
end
