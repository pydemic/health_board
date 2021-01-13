defmodule HealthBoardWeb.DashboardLive.DashboardData.FluSyndrome do
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Geo.Locations

  alias HealthBoard.Contexts.FluSyndrome.{
    DailyFluSyndromeCases,
    MonthlyFluSyndromeCases,
    PandemicFluSyndromeCases,
    WeeklyFluSyndromeCases
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
    |> fetch_states_incidence()
    |> fetch_cities_incidence()
    |> fetch_incidence()
    |> fetch_monthly_incidence()
    |> fetch_weekly_incidence()
    |> fetch_daily_incidence()
    |> fetch_day_states_incidence()
    |> fetch_day_cities_incidence()
    |> fetch_day_incidence()
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

  @states_incidence_keys [:states_ids]

  defp fetch_states_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @states_incidence_keys) do
      [context: :residence, locations_ids: data.states_ids]
      |> PandemicFluSyndromeCases.list_by()
      |> PandemicFluSyndromeCases.preload()
      |> Enum.map(&extract_states_incidence/1)
      |> put_data(:states_incidence, data)
    else
      data
    end
  end

  defp extract_states_incidence(%{location: location, confirmed: confirmed, discarded: discarded} = day_cases) do
    samples = confirmed + discarded

    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      confirmed: confirmed,
      samples: samples,
      health_professional: day_cases.health_professional,
      positivity_rate: Math.positivity_rate(confirmed, samples)
    }
  end

  @cities_incidence_keys [:cities_ids]

  defp fetch_cities_incidence(%{changed_filters: changes, states_incidence: states_incidence} = data) do
    if DataManager.filters_changed?(changes, @cities_incidence_keys) do
      [context: :residence, locations_ids: data.cities_ids]
      |> PandemicFluSyndromeCases.list_by()
      |> PandemicFluSyndromeCases.preload()
      |> Enum.map(&extract_cities_incidence(&1, states_incidence))
      |> put_data(:cities_incidence, data)
    else
      data
    end
  end

  defp extract_cities_incidence(day_cases, states_incidence) do
    %{location: location, confirmed: confirmed, discarded: discarded} = day_cases
    state_id = Locations.state_id(location.id, :city)

    location_name =
      case Enum.find_value(states_incidence, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    samples = confirmed + discarded

    %{
      location_id: location.id,
      location_name: location_name,
      confirmed: confirmed,
      samples: samples,
      health_professional: day_cases.health_professional,
      positivity_rate: Math.positivity_rate(confirmed, samples)
    }
  end

  @incidence_keys [:location_id]

  defp fetch_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @incidence_keys) do
      [context: :residence, location_id: data.location_id, default: :new]
      |> PandemicFluSyndromeCases.get_by()
      |> put_data(:incidence, data)
    else
      data
    end
  end

  @monthly_incidence_keys [:location_id]

  defp fetch_monthly_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @monthly_incidence_keys) do
      [context: :residence, location_id: data.location_id]
      |> MonthlyFluSyndromeCases.list_by()
      |> put_data(:monthly_incidence, data)
    else
      data
    end
  end

  @weekly_incidence_keys [:location_id]

  defp fetch_weekly_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_incidence_keys) do
      [context: :residence, location_id: data.location_id]
      |> WeeklyFluSyndromeCases.list_by()
      |> put_data(:weekly_incidence, data)
    else
      data
    end
  end

  @daily_incidence_keys [:location_id]

  defp fetch_daily_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @daily_incidence_keys) do
      [context: :residence, location_id: data.location_id]
      |> DailyFluSyndromeCases.list_by()
      |> put_data(:daily_incidence, data)

      # daily_incidence = DailyFluSyndromeCases.list_by(context: :residence, order_by: [desc: :date])

      # data = put_data(daily_incidence, :daily_incidence, data)

      # put_data(Map.get(Enum.at(daily_incidence, 0, %{}), :date), :last_record_date, data)
    else
      data
    end
  end

  @day_states_incidence_keys [:date, :states_ids]

  defp fetch_day_states_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_states_incidence_keys) do
      [context: :residence, locations_ids: data.states_ids, date: data.date]
      |> DailyFluSyndromeCases.list_by()
      |> DailyFluSyndromeCases.preload()
      |> Enum.map(&extract_states_incidence/1)
      |> put_data(:day_states_incidence, data)
    else
      data
    end
  end

  @day_cities_incidence_keys [:date, :cities_ids]

  defp fetch_day_cities_incidence(%{changed_filters: changes, day_states_incidence: states_incidence} = data) do
    if DataManager.filters_changed?(changes, @day_cities_incidence_keys) do
      [context: :residence, locations_ids: data.cities_ids, date: data.date]
      |> DailyFluSyndromeCases.list_by()
      |> DailyFluSyndromeCases.preload()
      |> Enum.map(&extract_cities_incidence(&1, states_incidence))
      |> put_data(:day_cities_incidence, data)
    else
      data
    end
  end

  @day_incidence_keys [:location_id, :date]

  defp fetch_day_incidence(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_incidence_keys) do
      [context: :residence, location_id: data.location_id, date: data.date, default: :new]
      |> DailyFluSyndromeCases.get_by()
      |> put_data(:day_incidence, data)
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
