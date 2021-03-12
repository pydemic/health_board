defmodule HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations.Weekly do
  alias HealthBoard.Contexts.Consolidations.WeeklyLocationsConsolidations
  alias HealthBoardWeb.DashboardLive.ElementsData
  alias HealthBoardWeb.DashboardLive.ElementsData.Database.Consolidations

  @spec get(map, atom, map, map, keyword) :: map
  def get(data, field, params, _filters, opts \\ []) do
    with {:ok, group} <- Consolidations.fetch_group(data, params, opts),
         {:ok, year} <- Consolidations.fetch_year(data, params, "year", opts),
         {:ok, week} <- Consolidations.fetch_week(data, params, "week", opts),
         {:ok, location_id} <- Consolidations.fetch_location_id(data, params, opts),
         {:ok, consolidation} <- do_get(params, group, year, week, location_id, opts) do
      Map.put(data, field, consolidation)
    else
      _ -> data
    end
  end

  defp do_get(params, group, year, week, location_id, opts) do
    manager_params =
      Consolidations.maybe_preload(params,
        consolidation_group_id: group,
        year: year,
        week: week,
        location_id: location_id
      )

    case ElementsData.apply_and_cache(WeeklyLocationsConsolidations, :get_by, [manager_params], opts) do
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
    |> Consolidations.maybe_append(Consolidations.fetch_years(data, params, opts))
    |> Consolidations.maybe_append(Consolidations.fetch_weeks(data, params, opts))
    |> maybe_create_period()
    |> Consolidations.maybe_append(Consolidations.fetch_locations_ids(data, params, opts))
    |> case do
      [] -> :error
      manager_params -> {:ok, do_list(params, [{:consolidation_group_id, group} | manager_params], opts)}
    end
  end

  defp maybe_create_period(keyword) do
    if length(keyword) == 4 do
      [
        {
          :period,
          %{
            from: %{year: Keyword.get(keyword, :from_year), week: Keyword.get(keyword, :from_week)},
            to: %{year: Keyword.get(keyword, :to_year), week: Keyword.get(keyword, :to_week)}
          }
        }
      ]
    else
      keyword
    end
  end

  defp do_list(params, manager_params, opts) do
    manager_params = Consolidations.maybe_preload(params, manager_params)

    WeeklyLocationsConsolidations
    |> ElementsData.apply_and_cache(:list_by, [manager_params], Keyword.put(opts, :default, []))
    |> Consolidations.maybe_sum_by(params)
  end
end
