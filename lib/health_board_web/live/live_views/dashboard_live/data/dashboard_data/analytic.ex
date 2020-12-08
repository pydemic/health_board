defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.YearlyMorbidities
  alias HealthBoard.Contexts.Mortalities.YearlyDeaths
  alias HealthBoardWeb.DashboardLive.CommonData

  @spec fetch(map) :: map
  def fetch(map) do
    map
    |> fetch_default_filters()
    |> fetch_location_data()
    |> fetch_deaths()
    |> fetch_yearly_morbidities()
    |> fetch_yearly_populations()
    |> fetch_data_periods()
  end

  defp fetch_default_filters(map) do
    current_year = Date.utc_today().year

    filters = %{year: current_year, to_year: current_year, from_year: 2000}

    map
    |> Map.update(:query_filters, filters, &Map.merge(&1, filters))
    |> Map.put(:filters, filters)
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
    %{location_id: location_id, year: year} = data

    yearly_deaths_per_context =
      [location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyDeaths.list_by()
      |> Enum.group_by(& &1.context, &Map.take(&1, [:year, :total]))

    locations_contexts_deaths =
      [year: year, locations_ids: data.locations_ids]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:context, :location_id, :total]))

    data =
      Map.merge(data, %{
        yearly_deaths_per_context: yearly_deaths_per_context,
        locations_contexts_deaths: locations_contexts_deaths
      })

    Map.put(map, :data, data)
  end

  defp fetch_yearly_morbidities(%{data: data} = map) do
    %{location_id: location_id, year: year} = data

    yearly_morbidities_per_context =
      [location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyMorbidities.list_by()
      |> Enum.group_by(& &1.context, &Map.take(&1, [:year, :total]))

    locations_contexts_morbidities =
      [year: year, locations_ids: data.locations_ids]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:context, :location_id, :total]))

    data =
      Map.merge(data, %{
        yearly_morbidities_per_context: yearly_morbidities_per_context,
        locations_contexts_morbidities: locations_contexts_morbidities
      })

    Map.put(map, :data, data)
  end

  defp fetch_yearly_populations(%{data: data} = map) do
    %{location_id: location_id, year: year} = data

    yearly_population =
      [location_id: location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))

    population =
      [location_id: location_id, year: year]
      |> YearlyPopulations.get_by()
      |> Map.get(:total, 0)

    locations_populations =
      [year: year, locations_ids: data.locations_ids]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))

    data =
      Map.merge(data, %{
        yearly_population: yearly_population,
        population: population,
        locations_populations: locations_populations
      })

    Map.put(map, :data, data)
  end

  defp fetch_data_periods(%{data: data} = map) do
    %{location_id: location_id} = data

    data_periods_per_context =
      [location_id: location_id, data_contexts: [Contexts.data_context!(:morbidity), Contexts.data_context!(:deaths)]]
      |> DataPeriods.list_by()
      |> Enum.group_by(& &1.context, &Map.delete(&1, :context))

    Map.update!(map, :data, &Map.put(&1, :data_periods_per_context, data_periods_per_context))
  end
end
