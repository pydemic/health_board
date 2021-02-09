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
    {
      Consolidations.fetch_years(data, params),
      Consolidations.fetch_weeks(data, params),
      Consolidations.fetch_locations_ids(data, params)
    }
    |> case do
      {:error, :error, :error} -> :error
      {:error, :error, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ lk)}
      {:error, {:ok, wk}, :error} -> {:ok, do_list([consolidation_group_id: group] ++ wk)}
      {:error, {:ok, wk}, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ wk ++ lk)}
      {{:ok, yk}, :error, :error} -> {:ok, do_list([consolidation_group_id: group] ++ yk)}
      {{:ok, yk}, :error, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ lk)}
      {{:ok, yk}, {:ok, wk}, :error} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ wk)}
      {{:ok, yk}, {:ok, wk}, {:ok, lk}} -> {:ok, do_list([consolidation_group_id: group] ++ yk ++ wk ++ lk)}
    end
  end

  defp do_list(manager_params) do
    ElementsData.database_data(WeeklyLocationsConsolidations, :list_by, [manager_params])
  end
end
