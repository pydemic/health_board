defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Morbidities.{WeeklyMorbidities, YearlyMorbidities}
  alias HealthBoard.Contexts.Mortalities.{WeeklyDeaths, YearlyDeaths}
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = dashboard_data) do
    filters = fetch_default_filters(filters)

    data
    |> Map.put(:location, CommonData.location(filters))
    |> fetch_locations()
    |> fetch_yearly_deaths(filters)
    |> fetch_yearly_morbidities(filters)
    |> fetch_yearly_populations(filters)
    |> fetch_locations_year_deaths(filters)
    |> fetch_locations_year_morbidities(filters)
    |> fetch_locations_year_populations(filters)
    |> fetch_weekly_deaths(filters)
    |> fetch_weekly_morbidities(filters)
    |> update(dashboard_data)
    |> Map.put(:filters, filters)
  end

  defp fetch_default_filters(filters) do
    current_year = Date.utc_today().year

    filters
    |> Map.put("time_year", current_year)
    |> Map.put("time_to_year", current_year)
    |> Map.put("time_from_year", 2000)
  end

  defp fetch_locations(%{location: location} = data) do
    locations =
      location
      |> CommonData.locations()
      |> Enum.sort(&(&1.name <= &2.name))

    data
    |> Map.put(:locations, locations)
    |> Map.put(:locations_ids, Enum.map(locations, & &1.id))
  end

  defp fetch_yearly_deaths(%{location: %{id: location_id}} = data, filters) do
    %{"time_from_year" => from_year, "time_to_year" => to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:yearly_deaths, data)
  end

  defp fetch_yearly_morbidities(%{location: %{id: location_id}} = data, filters) do
    %{"time_from_year" => from_year, "time_to_year" => to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:yearly_morbidities, data)
  end

  defp fetch_yearly_populations(%{location: %{id: location_id}} = data, filters) do
    %{"time_from_year" => from_year, "time_to_year" => to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
    |> update(:yearly_populations, data)
  end

  defp fetch_locations_year_deaths(%{locations_ids: locations_ids} = data, filters) do
    %{"time_year" => year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:locations_year_deaths, data)
  end

  defp fetch_locations_year_morbidities(%{locations_ids: locations_ids} = data, filters) do
    %{"time_year" => year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> update(:locations_year_morbidities, data)
  end

  defp fetch_locations_year_populations(%{locations_ids: locations_ids} = data, filters) do
    %{"time_year" => year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
    |> update(:locations_year_populations, data)
  end

  defp fetch_weekly_deaths(%{location: %{id: location_id}} = data, filters) do
    %{"time_from_year" => from_year, "time_to_year" => to_year} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> Enum.group_by(& &1.context)
    |> update(:weekly_deaths, data)
  end

  defp fetch_weekly_morbidities(%{location: %{id: location_id}} = data, filters) do
    %{"time_from_year" => from_year, "time_to_year" => to_year} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> Enum.group_by(& &1.context)
    |> update(:weekly_morbidities, data)
  end

  defp update(data, key \\ :data, dashboard_data) do
    Map.put(dashboard_data, key, data)
  end
end
