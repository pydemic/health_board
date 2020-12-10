defmodule HealthBoardWeb.DashboardLive.DashboardData.Analytic do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.YearlyMorbidities
  alias HealthBoard.Contexts.Mortalities.YearlyDeaths
  alias HealthBoardWeb.DashboardLive.{CommonData, DataManager, GroupData}
  alias Phoenix.LiveView

  @location_fields [
    :state,
    :health_region,
    :city
  ]

  @spec fetch(LiveView.Socket.t()) :: LiveView.Socket.t()
  def fetch(%{assigns: %{data: data, filters: filters, changed_filters: changed_filters}} = socket) do
    data
    |> Map.drop(@location_fields)
    |> Map.merge(filters)
    |> Map.put(:params, filters)
    |> Map.put(:changed_filters, changed_filters)
    |> fetch_location()
    |> fetch_yearly_deaths_per_context()
    |> fetch_year_locations_contexts_deaths()
    |> fetch_yearly_morbidities_per_context()
    |> fetch_year_locations_contexts_morbidities()
    |> fetch_yearly_population()
    |> fetch_year_locations_population()
    |> fetch_data_periods_per_context()
    |> put_data_in_socket(socket)
    |> fetch_groups()
  end

  @location_keys [:state, :health_region, :city]
  @locations_keys [:state, :states, :health_regions, :health_region, :cities, :city]

  defp fetch_location(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @location_keys) do
      location = CommonData.location(Map.take(data, @location_keys))
      locations = CommonData.locations(Map.take(data, @locations_keys), extra_params: [order_by: [asc: :name]])
      locations_ids = Enum.map(locations, & &1.id)
      locations_names = Enum.map(locations, & &1.name)

      Map.merge(data, %{
        location: location,
        location_id: location.id,
        location_name: location.name,
        locations: locations,
        locations_ids: locations_ids,
        locations_names: locations_names,
        changed_filters: DataManager.add_filter_change(changes, :location_id)
      })
    else
      data
    end
  end

  @yearly_deaths_per_context_keys [:location_id, :from_year, :to_year]

  defp fetch_yearly_deaths_per_context(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_deaths_per_context_keys) do
      [location_id: data.location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyDeaths.list_by()
      |> Enum.group_by(& &1.context, &Map.take(&1, [:year, :total]))
      |> put_data(:yearly_deaths_per_context, data)
    else
      data
    end
  end

  @year_locations_contexts_deaths_keys [:locations_ids, :year]

  defp fetch_year_locations_contexts_deaths(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_contexts_deaths_keys) do
      [locations_ids: data.locations_ids, year: data.year]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:context, :location_id, :total]))
      |> put_data(:year_locations_contexts_deaths, data)
    else
      data
    end
  end

  @yearly_morbidities_per_context_keys [:location_id, :from_year, :to_year]

  defp fetch_yearly_morbidities_per_context(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_morbidities_per_context_keys) do
      [location_id: data.location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyMorbidities.list_by()
      |> Enum.group_by(& &1.context, &Map.take(&1, [:year, :total]))
      |> put_data(:yearly_morbidities_per_context, data)
    else
      data
    end
  end

  @year_locations_contexts_morbidities_keys [:locations_ids, :year]

  defp fetch_year_locations_contexts_morbidities(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_contexts_morbidities_keys) do
      [locations_ids: data.locations_ids, year: data.year]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:context, :location_id, :total]))
      |> put_data(:year_locations_contexts_morbidities, data)
    else
      data
    end
  end

  @yearly_population_keys [:location_id, :from_year, :to_year]

  defp fetch_yearly_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_population_keys) do
      [location_id: data.location_id, from_year: data.from_year, to_year: data.to_year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))
      |> put_data(:yearly_population, data)
    else
      data
    end
  end

  @year_locations_population_keys [:locations_ids, :year]

  defp fetch_year_locations_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_population_keys) do
      [locations_ids: data.locations_ids, year: data.year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_locations_population, data)
    else
      data
    end
  end

  defp fetch_data_periods_per_context(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, :location_id) do
      [
        location_id: data.location_id,
        data_contexts: [Contexts.data_context!(:morbidity), Contexts.data_context!(:deaths)]
      ]
      |> DataPeriods.list_by()
      |> Enum.group_by(& &1.context, &Map.delete(&1, :context))
      |> put_data(:data_periods_per_context, data)
    else
      data
    end
  end

  defp put_data_in_socket(data, socket), do: LiveView.assign(socket, :data, data)

  defp fetch_groups(%{assigns: %{data: data}, root_pid: pid} = socket) do
    if DataManager.filters_changed?(data.changed_filters) do
      index = data[:index] || 0
      group = Enum.find(socket.assigns.dashboard.groups, &(&1.index == index))
      GroupData.request_to_fetch(pid, group, data)
    end

    socket
  end

  defp put_data(value, key, data) do
    data
    |> Map.put(key, value)
    |> Map.update!(:changed_filters, &DataManager.add_filter_change(&1, key))
  end
end
