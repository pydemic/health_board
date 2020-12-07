defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.{WeeklyMorbidities, YearlyMorbidities}
  alias HealthBoard.Contexts.Mortalities.{WeeklyDeaths, YearlyDeaths}
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = dashboard_data) do
    filters = fetch_default_filters(filters)
    data = fetch_location_data(data, filters)

    data
    |> async_stream(filters)
    |> Enum.reduce(data, fn {:ok, {key, value}}, data -> Map.put(data, key, value) end)
    |> update(dashboard_data)
    |> Map.put(:filters, filters)
  end

  defp fetch_default_filters(filters) do
    current_year = Date.utc_today().year

    filters
    |> Map.put(:year, current_year)
    |> Map.put(:to_year, current_year)
    |> Map.put(:from_year, 2000)
  end

  defp fetch_location_data(data, filters) do
    data
    |> Map.put(:location, CommonData.location(filters))
    |> fetch_locations()
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

  defp async_stream(data, filters) do
    [
      fn -> {:yearly_deaths, fetch_yearly_deaths(data, filters)} end,
      fn -> {:yearly_morbidities, fetch_yearly_morbidities(data, filters)} end,
      fn -> {:yearly_populations, fetch_yearly_populations(data, filters)} end,
      fn -> {:locations_year_deaths, fetch_locations_year_deaths(data, filters)} end,
      fn -> {:locations_year_morbidities, fetch_locations_year_morbidities(data, filters)} end,
      fn -> {:locations_year_populations, fetch_locations_year_populations(data, filters)} end,
      fn -> {:weekly_deaths, fetch_weekly_deaths(data, filters)} end,
      fn -> {:weekly_morbidities, fetch_weekly_morbidities(data, filters)} end,
      fn -> {:data_periods, fetch_data_periods(data)} end
    ]
    |> Task.async_stream(& &1.(), timeout: 10_000)
  end

  defp fetch_yearly_deaths(%{location: %{id: location_id}}, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
  end

  defp fetch_yearly_morbidities(%{location: %{id: location_id}}, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
  end

  defp fetch_yearly_populations(%{location: %{id: location_id}}, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    [location_id: location_id, from_year: from_year, to_year: to_year]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
  end

  defp fetch_locations_year_deaths(%{locations_ids: locations_ids}, filters) do
    %{year: year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
  end

  defp fetch_locations_year_morbidities(%{locations_ids: locations_ids}, filters) do
    %{year: year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
  end

  defp fetch_locations_year_populations(%{locations_ids: locations_ids}, filters) do
    %{year: year} = filters

    [year: year, locations_ids: locations_ids]
    |> YearlyPopulations.list_by()
    |> Enum.map(&Map.take(&1, [:location_id, :year, :total]))
  end

  defp fetch_weekly_deaths(%{location: %{id: location_id}}, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyDeaths.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> Enum.group_by(& &1.context)
  end

  defp fetch_weekly_morbidities(%{location: %{id: location_id}}, filters) do
    %{from_year: from_year, to_year: to_year} = filters

    [
      location_id: location_id,
      from_year: from_year,
      to_year: to_year,
      order_by: [asc: :context, asc: :year, asc: :week]
    ]
    |> WeeklyMorbidities.list_by()
    |> Enum.map(&Map.take(&1, [:context, :location_id, :year, :total]))
    |> Enum.group_by(& &1.context)
  end

  defp fetch_data_periods(%{location: %{id: location_id}}) do
    [location_id: location_id, data_contexts: [Contexts.data_context!(:morbidity), Contexts.data_context!(:deaths)]]
    |> DataPeriods.list_by()
    |> Enum.group_by(& &1.data_context)
    |> group_data_periods_by_context()
  end

  defp group_data_periods_by_context(data_periods_per_data_context) do
    for {data_context, data_periods} <- data_periods_per_data_context, into: %{} do
      {data_context, Enum.group_by(data_periods, & &1.context)}
    end
  end

  defp update(data, key \\ :data, dashboard_data) do
    Map.put(dashboard_data, key, data)
  end
end
