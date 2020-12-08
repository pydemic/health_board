defmodule HealthBoardWeb.DashboardLive.DashboardData.Morbidity do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.{WeeklyMorbidities, YearlyMorbidities}
  alias HealthBoard.Contexts.Mortalities.{WeeklyDeaths, YearlyDeaths}
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map) :: map
  def fetch(map) do
    map
    |> fetch_default_filters()
    |> fetch_location_data()
    |> fetch_deaths()
    |> fetch_morbidities()
    |> fetch_populations()
    |> fetch_data_periods()
  end

  defp fetch_default_filters(%{query_filters: query_filters} = map) do
    current_year = Date.utc_today().year

    morbidity_context = Map.get(query_filters, :morbidity_context, Contexts.morbidity!(:botulism))

    filters = %{year: current_year, to_year: current_year, from_year: 2000, morbidity_context: morbidity_context}

    map
    |> Map.update(:query_filters, filters, &Map.merge(&1, filters))
    |> Map.put(:filters, Map.update!(filters, :morbidity_context, &Contexts.morbidity_name/1))
    |> Map.put(:data, filters)
  end

  defp fetch_location_data(%{data: data, filters: filters, query_filters: query_filters} = map) do
    location = CommonData.location(query_filters)
    locations = fetch_locations(location)
    locations_ids = Enum.map(locations, & &1.id)
    locations_names = Enum.map(locations, & &1.name)

    data =
      Map.merge(data, %{
        location_id: location.id,
        location: location,
        locations: locations,
        locations_ids: locations_ids
      })

    filters = Map.merge(filters, %{location: location.name, locations: locations_names})
    Map.merge(map, %{data: data, filters: filters})
  end

  defp fetch_locations(location) do
    location
    |> CommonData.locations()
    |> Enum.sort(&(&1.name <= &2.name))
  end

  defp fetch_deaths(%{data: data} = map) do
    %{morbidity_context: context, location_id: location_id, year: year} = data

    year_deaths =
      [context: context, location_id: location_id, year: year, default: :new]
      |> YearlyDeaths.get_by()

    yearly_deaths =
      [context: context, location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    locations_deaths =
      [context: context, locations_ids: data.locations_ids, year: year]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))

    weekly_deaths =
      [context: context, location_id: location_id, year_to: year]
      |> WeeklyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    data =
      Map.merge(data, %{
        year_deaths: year_deaths,
        yearly_deaths: yearly_deaths,
        locations_deaths: locations_deaths,
        weekly_deaths: weekly_deaths
      })

    Map.put(map, :data, data)
  end

  defp fetch_morbidities(%{data: data} = map) do
    %{morbidity_context: context, location_id: location_id, year: year} = data

    year_morbidity =
      [context: context, location_id: location_id, year: year, default: :new]
      |> YearlyMorbidities.get_by()

    yearly_morbidity =
      [context: context, location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    locations_morbidity =
      [context: context, locations_ids: data.locations_ids, year: year]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))

    weekly_morbidity =
      [context: context, location_id: location_id, year_to: year]
      |> WeeklyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    data =
      Map.merge(data, %{
        year_morbidity: year_morbidity,
        yearly_morbidity: yearly_morbidity,
        locations_morbidity: locations_morbidity,
        weekly_morbidity: weekly_morbidity
      })

    Map.put(map, :data, data)
  end

  defp fetch_populations(%{data: data} = map) do
    %{location_id: location_id, year: year} = data

    year_population =
      [location_id: location_id, year: year, default: :new]
      |> YearlyPopulations.get_by()

    yearly_population =
      [location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    locations_population =
      [year: year, locations_ids: data.locations_ids]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))

    data =
      Map.merge(data, %{
        year_population: year_population,
        yearly_population: yearly_population,
        locations_population: locations_population
      })

    Map.put(map, :data, data)
  end

  defp fetch_data_periods(%{data: data} = map) do
    %{location_id: location_id} = data

    data_periods_per_context =
      [location_id: location_id, data_contexts: [Contexts.data_context!(:morbidity), Contexts.data_context!(:deaths)]]
      |> DataPeriods.list_by()
      |> Enum.group_by(& &1.context, &Map.delete(&1, :context))

    put_in(map, [:data, :data_periods_per_context], data_periods_per_context)
  end
end
