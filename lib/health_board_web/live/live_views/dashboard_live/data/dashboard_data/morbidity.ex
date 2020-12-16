defmodule HealthBoardWeb.DashboardLive.DashboardData.Morbidity do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Info.DataPeriods
  alias HealthBoard.Contexts.Morbidities.{WeeklyMorbidities, YearlyMorbidities}
  alias HealthBoard.Contexts.Mortalities.{WeeklyDeaths, YearlyDeaths}
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
    |> fetch_morbidity()
    |> fetch_time()
    |> fetch_location()
    |> fetch_yearly_deaths()
    |> fetch_weekly_deaths()
    |> fetch_year_locations_deaths()
    |> fetch_year_deaths()
    |> fetch_yearly_morbidity()
    |> fetch_weekly_morbidity()
    |> fetch_year_locations_morbidity()
    |> fetch_year_morbidity()
    |> fetch_yearly_population()
    |> fetch_year_locations_population()
    |> fetch_year_population()
    |> fetch_data_periods()
    |> put_data_in_socket(socket)
    |> fetch_groups()
  end

  @morbidity_keys [:morbidity_context]

  defp fetch_morbidity(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @morbidity_keys) do
      morbidity_context =
        Map.get_lazy(data, :morbidity_context, fn -> YearlyMorbidities.context!(:botulism, :residence) end)

      morbidity_name = Contexts.morbidity_name(morbidity_context)
      Map.merge(data, %{morbidity_context: morbidity_context, morbidity_name: morbidity_name})
    else
      data
    end
  end

  @time_keys [:from_week, :to_week]

  defp fetch_time(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @time_keys) do
      Map.merge(data, %{
        from_week: data[:from_week] || 1,
        to_week: data[:to_week] || 53
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

  @yearly_deaths_keys [:location_id, :from_year, :to_year, :morbidity_context]

  defp fetch_yearly_deaths(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_deaths_keys) do
      [location_id: data.location_id, from_year: data.from_year, to_year: data.to_year, context: data.morbidity_context]
      |> WeeklyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))
      |> put_data(:yearly_deaths, data)
    else
      data
    end
  end

  @weekly_deaths_keys [:location_id, :from_week, :to_week, :morbidity_context]

  defp fetch_weekly_deaths(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_deaths_keys) do
      [location_id: data.location_id, from_week: data.from_week, to_week: data.to_week, context: data.morbidity_context]
      |> WeeklyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:year, :week, :total]))
      |> put_data(:weekly_deaths, data)
    else
      data
    end
  end

  @year_locations_deaths_keys [:locations_ids, :year, :morbidity_context]

  defp fetch_year_locations_deaths(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_deaths_keys) do
      [locations_ids: data.locations_ids, year: data.year, context: data.morbidity_context]
      |> YearlyDeaths.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_locations_deaths, data)
    else
      data
    end
  end

  @year_deaths_keys [:location_id, :year, :morbidity_context]

  defp fetch_year_deaths(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_deaths_keys) do
      [location_id: data.location_id, year: data.year, context: data.morbidity_context, default: :new]
      |> YearlyDeaths.get_by()
      |> put_data(:year_deaths, data)
    else
      data
    end
  end

  @yearly_morbidity_keys [:location_id, :from_year, :to_year, :morbidity_context]

  defp fetch_yearly_morbidity(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @yearly_morbidity_keys) do
      [location_id: data.location_id, from_year: data.from_year, to_year: data.to_year, context: data.morbidity_context]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:year, :total]))
      |> put_data(:yearly_morbidity, data)
    else
      data
    end
  end

  @weekly_morbidity_keys [:location_id, :from_week, :to_week, :morbidity_context]

  defp fetch_weekly_morbidity(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_morbidity_keys) do
      [location_id: data.location_id, from_week: data.from_week, to_week: data.to_week, context: data.morbidity_context]
      |> WeeklyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:year, :week, :total]))
      |> put_data(:weekly_morbidity, data)
    else
      data
    end
  end

  @year_locations_morbidity_keys [:locations_ids, :year, :morbidity_context]

  defp fetch_year_locations_morbidity(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_locations_morbidity_keys) do
      [locations_ids: data.locations_ids, year: data.year, context: data.morbidity_context]
      |> YearlyMorbidities.list_by()
      |> Enum.map(&Map.take(&1, [:context, :location_id, :total]))
      |> put_data(:year_locations_morbidity, data)
    else
      data
    end
  end

  @year_morbidity_keys [:location_id, :year, :morbidity_context]

  defp fetch_year_morbidity(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_morbidity_keys) do
      [location_id: data.location_id, year: data.year, context: data.morbidity_context, default: :new]
      |> YearlyMorbidities.get_by()
      |> put_data(:year_morbidity, data)
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

  @data_periods_keys [:location_id, :morbidity_context]

  defp fetch_data_periods(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @data_periods_keys) do
      morbidity_data_context = Contexts.data_context!(:morbidity)
      deaths_data_context = Contexts.data_context!(:deaths)

      data_periods =
        DataPeriods.list_by(
          location_id: data.location_id,
          data_contexts: [morbidity_data_context, deaths_data_context],
          context: data.morbidity_context
        )

      empty_data_period = DataPeriods.new()

      Map.merge(data, %{
        morbidity_data_period: Enum.find(data_periods, empty_data_period, &(&1.data_context == morbidity_data_context)),
        deaths_data_period: Enum.find(data_periods, empty_data_period, &(&1.data_context == deaths_data_context))
      })
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
