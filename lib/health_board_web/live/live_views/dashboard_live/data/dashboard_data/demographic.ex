defmodule HealthBoardWeb.DashboardLive.DashboardData.Demographic do
  alias HealthBoard.Contexts.Demographic.{YearlyBirths, YearlyPopulations}
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
    |> fetch_time()
    |> fetch_location()
    |> fetch_yearly_population()
    |> fetch_year_locations_population()
    |> fetch_year_population()
    |> fetch_yearly_births()
    |> fetch_year_locations_births()
    |> fetch_year_births()
    |> put_data_in_socket(socket)
    |> fetch_groups()
  end

  @time_keys [:year, :from_year, :to_year]

  defp fetch_time(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @time_keys) do
      Map.merge(data, %{
        births_year: Statistics.max([data.year - 1, 2000]),
        births_from_year: Statistics.max([data.from_year - 1, 2000]),
        births_to_year: Statistics.min([data.to_year - 1, 2018])
      })
    else
      data
    end
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
        changed_filters: DataManager.add_filter_change(changes, [:location_id, :locations_ids])
      })
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

  @year_population_keys [:location_id, :year]

  defp fetch_year_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_population_keys) do
      [location_id: data.location_id, year: data.year, default: :new]
      |> YearlyPopulations.get_by()
      |> put_data(:year_population, data)
    else
      data
    end
  end

  @yearly_births_keys [:location_id, :from_year, :to_year]

  defp fetch_yearly_births(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_births_keys) do
      [
        location_id: data.location_id,
        from_year: data.births_from_year,
        to_year: data.births_to_year,
        context: YearlyBirths.context!(:residence)
      ]
      |> YearlyBirths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))
      |> put_data(:yearly_births, data)
    else
      data
    end
  end

  @year_locations_births_keys [:locations_ids, :year]

  defp fetch_year_locations_births(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_births_keys) do
      [locations_ids: data.locations_ids, year: data.births_year - 1, context: YearlyBirths.context!(:residence)]
      |> YearlyBirths.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_locations_births, data)
    else
      data
    end
  end

  @year_births_keys [:location_id, :year]

  defp fetch_year_births(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_births_keys) do
      [
        location_id: data.location_id,
        year: data.births_year - 1,
        context: YearlyBirths.context!(:residence),
        default: :new
      ]
      |> YearlyBirths.get_by()
      |> put_data(:year_births, data)
    else
      data
    end
  end

  defp put_data_in_socket(data, socket), do: LiveView.assign(socket, :data, data)

  defp fetch_groups(%{assigns: %{data: data}, root_pid: pid} = socket) do
    if DataManager.filters_changed?(data.changed_filters) do
      [group | _groups] = socket.assigns.dashboard.groups

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
