defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Morbidities.YearlyMorbidities
  alias HealthBoard.Contexts.Mortalities.YearlyDeaths
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = dashboard_data) do
    data
    |> Map.put(:location, CommonData.location(filters))
    |> fetch_children_locations()
    |> fetch_yearly_deaths()
    |> fetch_yearly_morbidities()
    |> fetch_yearly_populations()
    |> fetch_locations_yearly_deaths()
    |> fetch_locations_yearly_morbidities()
    |> fetch_locations_yearly_populations()
    |> update(dashboard_data)
  end

  defp fetch_children_locations(%{location: location} = data) do
    locations =
      location
      |> CommonData.children_locations()
      |> Enum.sort(&(&1.name <= &2.name))

    data
    |> Map.put(:children_locations, locations)
    |> Map.put(:children_locations_ids, Enum.map(locations, & &1.id))
  end

  defp fetch_yearly_deaths(%{location: %{id: location_id}} = data) do
    [location_id: location_id]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:yearly_deaths, data)
  end

  defp fetch_yearly_morbidities(%{location: %{id: location_id}} = data) do
    [location_id: location_id]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:yearly_morbidities, data)
  end

  defp fetch_yearly_populations(%{location: %{id: location_id}} = data) do
    [location_id: location_id]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
    |> update(:yearly_populations, data)
  end

  defp fetch_locations_yearly_deaths(%{children_locations_ids: locations_ids} = data) do
    [year: 2020, locations_ids: locations_ids]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:locations_yearly_deaths, data)
  end

  defp fetch_locations_yearly_morbidities(%{children_locations_ids: locations_ids} = data) do
    [year: 2020, locations_ids: locations_ids]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:locations_yearly_morbidities, data)
  end

  defp fetch_locations_yearly_populations(%{children_locations_ids: locations_ids} = data) do
    [year: 2020, locations_ids: locations_ids]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
    |> update(:locations_yearly_populations, data)
  end

  defp update(data, key \\ :data, dashboard_data) do
    Map.put(dashboard_data, key, data)
  end
end
