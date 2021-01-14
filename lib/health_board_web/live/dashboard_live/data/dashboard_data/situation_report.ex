defmodule HealthBoardWeb.DashboardLive.DashboardData.SituationReport do
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Geo.Locations

  alias HealthBoard.Contexts.SituationReport.{
    DailyCOVIDReports,
    MonthlyCOVIDReports,
    PandemicCOVIDReports,
    WeeklyCOVIDReports
  }

  alias HealthBoardWeb.DashboardLive.{CommonData, DataManager, GroupData}
  alias HealthBoardWeb.Helpers.Math
  alias Phoenix.LiveView

  @spec fetch(LiveView.Socket.t()) :: LiveView.Socket.t()
  def fetch(%{assigns: %{data: data, filters: filters, changed_filters: changed_filters}} = socket) do
    data
    |> Map.drop([:region, :state, :health_region, :city])
    |> Map.merge(filters)
    |> Map.put(:params, filters)
    |> Map.put(:changed_filters, changed_filters)
    |> fetch_location()
    |> fetch_states()
    |> fetch_cities()
    |> fetch_states_covid_reports()
    |> fetch_cities_covid_reports()
    |> fetch_covid_reports()
    |> fetch_monthly_covid_reports()
    |> fetch_weekly_covid_reports()
    |> fetch_daily_covid_reports()
    |> fetch_day_states_covid_reports()
    |> fetch_day_cities_covid_reports()
    |> fetch_day_covid_reports()
    |> fetch_year_states_population()
    |> fetch_year_cities_population()
    |> fetch_year_population()
    |> put_data_in_socket(socket)
    |> fetch_groups()
  end

  @location_keys [:region, :state, :health_region, :city]

  defp fetch_location(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @location_keys) do
      location = CommonData.location(Map.take(data, @location_keys))

      Map.merge(data, %{
        location: location,
        location_context: Locations.context(location.context),
        location_id: location.id,
        location_name: location.name,
        changed_filters: DataManager.add_filter_change(changes, :location_id)
      })
    else
      data
    end
  end

  @states_keys [:region, :state]

  defp fetch_states(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @states_keys) do
      %{location_context: location_context, location_id: location_id} = data

      case location_context do
        :country -> Locations.list_children(location_id, :state)
        :region -> Locations.list_children(location_id, :state)
        :state -> Locations.list_siblings(location_id)
        :health_region -> Locations.list_siblings(Locations.state_id(location_id, :health_region))
        :city -> Locations.list_siblings(Locations.state_id(location_id, :city))
      end
      |> Enum.map(& &1.id)
      |> put_data(:states_ids, data)
    else
      data
    end
  end

  @cities_keys [:region, :state, :health_region]

  defp fetch_cities(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @cities_keys) do
      %{location_context: location_context, location_id: location_id} = data

      case location_context do
        :city -> Locations.list_siblings(location_id)
        _context -> Locations.list_children(location_id, :city)
      end
      |> Enum.map(& &1.id)
      |> put_data(:cities_ids, data)
    else
      data
    end
  end

  @states_covid_reports_keys [:states_ids]

  defp fetch_states_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @states_covid_reports_keys) do
      [locations_ids: data.states_ids]
      |> PandemicCOVIDReports.list_by()
      |> PandemicCOVIDReports.preload()
      |> Enum.map(&extract_states_covid_reports/1)
      |> put_data(:states_covid_reports, data)
    else
      data
    end
  end

  defp extract_states_covid_reports(%{location: location, cases: incidence, deaths: deaths}) do
    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      incidence: incidence,
      deaths: deaths,
      fatality_rate: Math.fatality_rate(deaths, incidence)
    }
  end

  @cities_covid_reports_keys [:cities_ids]

  defp fetch_cities_covid_reports(%{changed_filters: changes, states_covid_reports: states_covid_reports} = data) do
    if DataManager.filters_changed?(changes, @cities_covid_reports_keys) do
      [locations_ids: data.cities_ids]
      |> PandemicCOVIDReports.list_by()
      |> PandemicCOVIDReports.preload()
      |> Enum.map(&extract_cities_covid_reports(&1, states_covid_reports))
      |> put_data(:cities_covid_reports, data)
    else
      data
    end
  end

  defp extract_cities_covid_reports(day_reports, states_covid_reports) do
    %{location: location, cases: incidence, deaths: deaths} = day_reports
    state_id = Locations.state_id(location.id, :city)

    location_name =
      case Enum.find_value(states_covid_reports, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    %{
      location_id: location.id,
      location_name: location_name,
      incidence: incidence,
      deaths: deaths,
      fatality_rate: Math.fatality_rate(deaths, incidence)
    }
  end

  @covid_reports_keys [:location_id]

  defp fetch_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @covid_reports_keys) do
      [location_id: data.location_id, default: :new]
      |> PandemicCOVIDReports.get_by()
      |> put_data(:covid_reports, data)
    else
      data
    end
  end

  @monthly_covid_reports_keys [:location_id]

  defp fetch_monthly_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @monthly_covid_reports_keys) do
      [location_id: data.location_id]
      |> MonthlyCOVIDReports.list_by()
      |> put_data(:monthly_covid_reports, data)
    else
      data
    end
  end

  @weekly_covid_reports_keys [:location_id]

  defp fetch_weekly_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_covid_reports_keys) do
      [location_id: data.location_id]
      |> WeeklyCOVIDReports.list_by()
      |> put_data(:weekly_covid_reports, data)
    else
      data
    end
  end

  @daily_covid_reports_keys [:location_id]

  defp fetch_daily_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @daily_covid_reports_keys) do
      daily_covid_reports = DailyCOVIDReports.list_by(location_id: data.location_id, order_by: [desc: :date])

      data = put_data(daily_covid_reports, :daily_covid_reports, data)

      put_data(Map.get(Enum.at(daily_covid_reports, 0, %{}), :date), :last_record_date, data)
    else
      data
    end
  end

  @day_states_covid_reports_keys [:date, :states_ids]

  defp fetch_day_states_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_states_covid_reports_keys) do
      [locations_ids: data.states_ids, date: data.date]
      |> DailyCOVIDReports.list_by()
      |> DailyCOVIDReports.preload()
      |> Enum.map(&extract_states_covid_reports/1)
      |> put_data(:day_states_covid_reports, data)
    else
      data
    end
  end

  @day_cities_covid_reports_keys [:date, :cities_ids]

  defp fetch_day_cities_covid_reports(
         %{changed_filters: changes, day_states_covid_reports: states_covid_reports} = data
       ) do
    if DataManager.filters_changed?(changes, @day_cities_covid_reports_keys) do
      [locations_ids: data.cities_ids, date: data.date]
      |> DailyCOVIDReports.list_by()
      |> DailyCOVIDReports.preload()
      |> Enum.map(&extract_cities_covid_reports(&1, states_covid_reports))
      |> put_data(:day_cities_covid_reports, data)
    else
      data
    end
  end

  @day_covid_reports_keys [:location_id, :date]

  defp fetch_day_covid_reports(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_covid_reports_keys) do
      [location_id: data.location_id, date: data.date, default: :new]
      |> DailyCOVIDReports.get_by()
      |> put_data(:day_covid_reports, data)
    else
      data
    end
  end

  @year_states_population_keys [:date, :states_ids]

  defp fetch_year_states_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_states_population_keys) do
      [locations_ids: data.states_ids, year: data.date.year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_states_population, data)
    else
      data
    end
  end

  @year_cities_population_keys [:date, :cities_ids]

  defp fetch_year_cities_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_cities_population_keys) do
      [locations_ids: data.cities_ids, year: data.date.year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_cities_population, data)
    else
      data
    end
  end

  @year_population_keys [:date, :location_id]

  defp fetch_year_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_population_keys) do
      [location_id: data.location_id, year: data.date.year, default: :new]
      |> YearlyPopulations.get_by()
      |> put_data(:year_population, data)
    else
      data
    end
  end

  defp put_data_in_socket(data, socket), do: LiveView.assign(socket, :data, data)

  defp fetch_groups(%{assigns: %{data: data}, root_pid: pid} = socket) do
    if DataManager.filters_changed?(data.changed_filters) do
      index = data[:index] || 0
      group = Enum.find(socket.assigns.dashboard.groups, &(&1.index == index))

      unless is_nil(group) do
        GroupData.request_to_fetch(pid, group, data)
      end
    end

    socket
  end

  defp put_data(value, key, data) do
    data
    |> Map.put(key, value)
    |> Map.update!(:changed_filters, &DataManager.add_filter_change(&1, key))
  end
end
