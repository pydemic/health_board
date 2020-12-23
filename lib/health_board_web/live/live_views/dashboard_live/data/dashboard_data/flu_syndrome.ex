defmodule HealthBoardWeb.DashboardLive.DashboardData.FluSyndrome do
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.FluSyndrome.{DailyFluSyndromeCases, MonthlyFluSyndromeCases, WeeklyFluSyndromeCases}
  alias HealthBoardWeb.DashboardLive.{CommonData, DataManager, GroupData}
  alias Phoenix.LiveView

  @spec fetch(LiveView.Socket.t()) :: LiveView.Socket.t()
  def fetch(%{assigns: %{data: data, filters: filters, changed_filters: changed_filters}} = socket) do
    data
    |> Map.drop([:state, :health_region, :city])
    |> Map.merge(filters)
    |> Map.put(:params, filters)
    |> Map.put(:changed_filters, changed_filters)
    |> fetch_location()
    |> fetch_monthly_cases()
    |> fetch_weekly_cases()
    |> fetch_daily_cases()
    |> fetch_day_states_cases()
    |> fetch_day_cities_cases()
    |> fetch_day_cases()
    |> fetch_year_states_population()
    |> fetch_year_cities_population()
    |> fetch_year_population()
    |> put_data_in_socket(socket)
    |> fetch_groups()
  end

  @location_keys [:state, :health_region, :city]

  defp fetch_location(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @location_keys) do
      location = CommonData.location(Map.take(data, @location_keys))

      Map.merge(data, %{
        location_id: location.id,
        location_name: location.name,
        changed_filters: DataManager.add_filter_change(changes, :location_id)
      })
    else
      data
    end
  end

  @monthly_cases_keys [:from_year, :to_year, :location_id]

  defp fetch_monthly_cases(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @monthly_cases_keys) do
      [context: :residence, location_id: data.location_id, from_year: data.from_year, to_year: data.to_year]
      |> MonthlyFluSyndromeCases.list_by()
      |> put_data(:monthly_cases, data)
    else
      data
    end
  end

  @weekly_cases_keys [:from_year, :to_year, :location_id]

  defp fetch_weekly_cases(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_cases_keys) do
      [context: :residence, location_id: data.location_id, from_year: data.from_year, to_year: data.to_year]
      |> WeeklyFluSyndromeCases.list_by()
      |> put_data(:weekly_cases, data)
    else
      data
    end
  end

  @daily_cases_keys [:from_date, :to_date, :location_id]

  defp fetch_daily_cases(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @daily_cases_keys) do
      [context: :residence, location_id: data.location_id, from_date: data.from_date, to_date: data.to_date]
      |> DailyFluSyndromeCases.list_by()
      |> put_data(:daily_cases, data)
    else
      data
    end
  end

  @day_states_cases_keys [:date]

  defp fetch_day_states_cases(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_states_cases_keys) do
      [context: :residence, locations_context: :state, date: data.date]
      |> DailyFluSyndromeCases.list_by()
      |> DailyFluSyndromeCases.preload()
      |> Enum.map(&extract_states_cases/1)
      |> put_data(:day_states_cases, data)
    else
      data
    end
  end

  defp extract_states_cases(%{location: location, confirmed: confirmed, discarded: discarded}) do
    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      confirmed: confirmed,
      positivity_rate: confirmed * 100 / (confirmed + discarded)
    }
  end

  @day_cities_cases_keys [:date]

  defp fetch_day_cities_cases(%{changed_filters: changes, day_states_cases: states_cases} = data) do
    if DataManager.filters_changed?(changes, @day_cities_cases_keys) do
      [context: :residence, locations_context: :city, date: data.date]
      |> DailyFluSyndromeCases.list_by()
      |> DailyFluSyndromeCases.preload()
      |> Enum.map(&extract_cities_cases(&1, states_cases))
      |> put_data(:day_cities_cases, data)
    else
      data
    end
  end

  defp extract_cities_cases(%{location: location, confirmed: confirmed, discarded: discarded}, states_cases) do
    state_id = div(location.id, 100_000)

    location_name =
      case Enum.find_value(states_cases, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    %{
      location_id: location.id,
      location_name: location_name,
      confirmed: confirmed,
      positivity_rate: confirmed * 100 / (confirmed + discarded)
    }
  end

  @day_cases_keys [:location_id, :date]

  defp fetch_day_cases(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_cases_keys) do
      [context: :residence, location_id: data.location_id, date: data.date, default: :new]
      |> DailyFluSyndromeCases.get_by()
      |> put_data(:day_cases, data)
    else
      data
    end
  end

  @year_cities_population_keys [:year]

  defp fetch_year_cities_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_cities_population_keys) do
      [locations_context: :city, year: data.year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_cities_population, data)
    else
      data
    end
  end

  @year_states_population_keys [:year]

  defp fetch_year_states_population(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @year_states_population_keys) do
      [locations_context: :state, year: data.year]
      |> YearlyPopulations.list_by()
      |> Enum.map(&Map.take(&1, [:location_id, :total]))
      |> put_data(:year_states_population, data)
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
