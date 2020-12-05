defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts.Morbidities.YearlyMorbidities
  alias HealthBoard.Contexts.Mortalities.YearlyDeaths
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = dashboard_data) do
    data
    |> Map.put(:location, CommonData.location(filters))
    |> fetch_deaths()
    |> fetch_morbidities()
    |> update(dashboard_data)
  end

  defp fetch_deaths(%{location: %{id: location_id}} = data) do
    [location_id: location_id]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:deaths, data)
  end

  defp fetch_morbidities(%{location: %{id: location_id}} = data) do
    [location_id: location_id]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:morbidities, data)
  end

  defp update(data, key \\ :data, dashboard_data) do
    Map.put(dashboard_data, key, data)
  end
end
