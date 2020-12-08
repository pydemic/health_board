defmodule HealthBoardWeb.DashboardLive.DashboardData.Morbidity do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.{WeeklyMorbidities, YearlyMorbidities}
  alias HealthBoard.Contexts.Mortalities.{WeeklyDeaths, YearlyDeaths}
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map) :: map
  def fetch(%{data: data, filters: filters} = dashboard_data) do
    {data, filters} = fetch_location_data(data, fetch_default_filters(filters))

    data
    |> fetch_yearly_deaths(filters)
    |> fetch_yearly_morbidities(filters)
    |> fetch_yearly_population(filters)
    |> fetch_locations_year_deaths(filters)
    |> fetch_locations_year_morbidities(filters)
    |> fetch_locations_year_populations(filters)
    |> fetch_weekly_deaths(filters)
    |> fetch_weekly_morbidities(filters)
    |> fetch_data_periods(filters)
    |> update(dashboard_data)
    |> Map.put(:filters, filters)
  end

  defp fetch_default_filters(filters) do
    current_year = Date.utc_today().year

    filters
    |> Map.put(:year, current_year)
    |> Map.put(:to_year, current_year)
    |> Map.put(:from_year, 2000)
    |> Map.put_new(:morbidity_context, 100_000)
  end

  defp fetch_location_data(data, filters) do
    location = CommonData.location(filters)

    data =
      data
      |> Map.put(:location, CommonData.location(filters))
      |> fetch_locations()

    {data, Map.put(filters, :location, location.name)}
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
    %{from_year: from_year, to_year: to_year, morbidity_context: context} = filters

    yearly_deaths =
      [location_id: location_id, from_year: from_year, to_year: to_year, context: context]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    %{total: year_deaths} = Enum.find(yearly_deaths, %{total: 0}, &(&1.year == to_year))

    data
    |> Map.put(:yearly_deaths, yearly_deaths)
    |> Map.put(:year_deaths, year_deaths)
  end

  defp fetch_yearly_morbidities(%{location: %{id: location_id}} = data, filters) do
    %{from_year: from_year, to_year: to_year, morbidity_context: context} = filters

    yearly_morbidities =
      [location_id: location_id, from_year: from_year, to_year: to_year, context: context]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    %{total: year_morbidity} = Enum.find(yearly_morbidities, %{total: 0}, &(&1.year == to_year))

    data
    |> Map.put(:yearly_morbidities, yearly_morbidities)
    |> Map.put(:year_morbidity, year_morbidity)
  end

  defp fetch_yearly_population(%{location: %{id: location_id}} = data, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    yearly_population =
      [location_id: location_id, from_year: from_year, to_year: to_year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    %{total: year_population} = Enum.find(yearly_population, %{total: 0}, &(&1.year == to_year))

    data
    |> Map.put(:yearly_population, yearly_population)
    |> Map.put(:year_population, year_population)
  end

  defp fetch_locations_year_deaths(%{locations_ids: locations_ids} = data, filters) do
    %{year: year, morbidity_context: context} = filters

    [year: year, locations_ids: locations_ids, context: context]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :total]))
    |> update(:locations_year_deaths, data)
  end

  defp fetch_locations_year_morbidities(%{locations_ids: locations_ids} = data, filters) do
    %{year: year, morbidity_context: context} = filters

    [year: year, locations_ids: locations_ids, context: context]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :total]))
    |> update(:locations_year_morbidities, data)
  end

  defp fetch_locations_year_populations(%{locations_ids: locations_ids} = data, filters) do
    %{year: year, morbidity_context: context} = filters

    [year: year, locations_ids: locations_ids, context: context]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :total]))
    |> update(:locations_year_populations, data)
  end

  defp fetch_weekly_deaths(%{location: %{id: location_id}} = data, filters) do
    %{from_year: from_year, to_year: to_year, morbidity_context: context} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      context: context,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:year, :week, :total]))
    |> update(:weekly_deaths, data)
  end

  defp fetch_weekly_morbidities(%{location: %{id: location_id}} = data, filters) do
    %{from_year: from_year, to_year: to_year, morbidity_context: context} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      context: context,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:year, :week, :total]))
    |> update(:weekly_morbidities, data)
  end

  defp fetch_data_periods(%{location: %{id: location_id}} = data, filters) do
    %{morbidity_context: context} = filters

    [
      location_id: location_id,
      data_contexts: [Contexts.data_context!(:morbidity), Contexts.data_context!(:deaths)],
      context: context
    ]
    |> DataPeriods.list_by()
    |> update(:data_periods, data)
  end

  defp update(data, key \\ :data, dashboard_data) do
    Map.put(dashboard_data, key, data)
  end
end
