defmodule HealthBoardWeb.DashboardLive.DashboardData.Sars do
  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Demographic.YearlyPopulations
  alias HealthBoard.Contexts.Geo.Locations

  alias HealthBoard.Contexts.SARS.{
    DailySARSCases,
    MonthlySARSCases,
    PandemicSARSCases,
    PandemicSARSSymptoms,
    WeeklySARSCases
  }

  alias HealthBoardWeb.DashboardLive.{CommonData, DataManager, GroupData}
  alias HealthBoardWeb.Helpers.Math
  alias Phoenix.LiveView

  @cases_residence Contexts.registry_location!(:cases_residence)
  @deaths_residence Contexts.registry_location!(:deaths_residence)
  @hospitalizations_residence Contexts.registry_location!(:hospitalizations_residence)
  @contexts [@cases_residence, @deaths_residence, @hospitalizations_residence]

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
    |> fetch_states_consolidations()
    |> fetch_cities_consolidations()
    |> fetch_symptoms()
    |> fetch_consolidations()
    |> fetch_monthly_consolidations()
    |> fetch_weekly_consolidations()
    |> fetch_daily_consolidations()
    |> fetch_day_states_consolidations()
    |> fetch_day_cities_consolidations()
    |> fetch_day_consolidations()
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

  @states_consolidations_keys [:states_ids]

  defp fetch_states_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @states_consolidations_keys) do
      [contexts: @contexts, locations_ids: data.states_ids]
      |> PandemicSARSCases.list_by()
      |> PandemicSARSCases.preload()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_states_consolidation/2)
      |> put_new_data(:states_incidence, [])
      |> put_new_data(:states_deaths, [])
      |> put_new_data(:states_hospitalizations, [])
    else
      data
    end
  end

  defp fetch_states_consolidation({context, consolidation}, data) do
    case context do
      @cases_residence ->
        consolidation
        |> Enum.map(&extract_states_incidence/1)
        |> put_data(:states_incidence, data)

      @deaths_residence ->
        consolidation
        |> Enum.map(&extract_states_deaths/1)
        |> put_data(:states_deaths, data)

      @hospitalizations_residence ->
        consolidation
        |> Enum.map(&extract_states_hospitalizations/1)
        |> put_data(:states_hospitalizations, data)
    end
  end

  defp extract_states_incidence(%{location: location, confirmed: confirmed, samples: samples} = day_cases) do
    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      confirmed: confirmed,
      samples: samples,
      positivity_rate: Math.positivity_rate(confirmed, samples),
      test_capacity: Math.test_capacity(confirmed, confirmed + day_cases.discarded)
    }
  end

  defp extract_states_deaths(%{location: location, confirmed: confirmed}) do
    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      confirmed: confirmed
    }
  end

  defp extract_states_hospitalizations(%{location: location, confirmed: confirmed}) do
    %{
      location_id: location.id,
      location_name: location.name,
      location_abbr: location.abbr,
      confirmed: confirmed
    }
  end

  @cities_consolidations_keys [:cities_ids]

  defp fetch_cities_consolidations(%{changed_filters: changes, states_incidence: states_incidence} = data) do
    if DataManager.filters_changed?(changes, @cities_consolidations_keys) do
      [contexts: @contexts, locations_ids: data.cities_ids]
      |> PandemicSARSCases.list_by()
      |> PandemicSARSCases.preload()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_cities_consolidation(&1, &2, states_incidence))
      |> put_new_data(:cities_incidence, [])
      |> put_new_data(:cities_deaths, [])
      |> put_new_data(:cities_hospitalizations, [])
    else
      data
    end
  end

  defp fetch_cities_consolidation({context, consolidation}, data, states_incidence) do
    case context do
      @cases_residence ->
        consolidation
        |> Enum.map(&extract_cities_incidence(&1, states_incidence))
        |> put_data(:cities_incidence, data)

      @deaths_residence ->
        consolidation
        |> Enum.map(&extract_cities_deaths(&1, states_incidence))
        |> put_data(:cities_deaths, data)

      @hospitalizations_residence ->
        consolidation
        |> Enum.map(&extract_cities_hospitalizations(&1, states_incidence))
        |> put_data(:cities_hospitalizations, data)
    end
  end

  defp extract_cities_incidence(day_cases, states_incidence) do
    %{location: location, confirmed: confirmed, discarded: discarded, samples: samples} = day_cases
    state_id = Locations.state_id(location.id, :city)

    location_name =
      case Enum.find_value(states_incidence, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    %{
      location_id: location.id,
      location_name: location_name,
      confirmed: confirmed,
      samples: samples,
      positivity_rate: Math.positivity_rate(confirmed, samples),
      test_capacity: Math.test_capacity(confirmed, confirmed + discarded)
    }
  end

  defp extract_cities_deaths(day_cases, states_incidence) do
    %{location: location, confirmed: confirmed} = day_cases
    state_id = Locations.state_id(location.id, :city)

    location_name =
      case Enum.find_value(states_incidence, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    %{
      location_id: location.id,
      location_name: location_name,
      confirmed: confirmed
    }
  end

  defp extract_cities_hospitalizations(day_cases, states_incidence) do
    %{location: location, confirmed: confirmed} = day_cases
    state_id = Locations.state_id(location.id, :city)

    location_name =
      case Enum.find_value(states_incidence, &if(&1.location_id == state_id, do: &1.location_abbr)) do
        nil -> location.name
        state_abbr -> "#{location.name} - #{state_abbr}"
      end

    %{
      location_id: location.id,
      location_name: location_name,
      confirmed: confirmed
    }
  end

  @symptoms_keys [:location_id]

  defp fetch_symptoms(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @symptoms_keys) do
      [context: :residence, location_id: data.location_id, default: :new]
      |> PandemicSARSSymptoms.get_by()
      |> put_data(:symptoms, data)
    else
      data
    end
  end

  @consolidations_keys [:location_id]

  defp fetch_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @consolidations_keys) do
      [contexts: @contexts, location_id: data.location_id]
      |> PandemicSARSCases.list_by()
      |> Enum.reduce(data, &fetch_consolidation/2)
      |> put_new_data_lazy(:incidence, &PandemicSARSCases.new/0)
      |> put_new_data_lazy(:deaths, &PandemicSARSCases.new/0)
      |> put_new_data_lazy(:hospitalizations, &PandemicSARSCases.new/0)
    else
      data
    end
  end

  defp fetch_consolidation(%{context: context} = cases, data) do
    case context do
      @cases_residence -> put_data(cases, :incidence, data)
      @deaths_residence -> put_data(cases, :deaths, data)
      @hospitalizations_residence -> put_data(cases, :hospitalizations, data)
    end
  end

  @monthly_consolidations_keys [:location_id]

  defp fetch_monthly_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @monthly_consolidations_keys) do
      [contexts: [@cases_residence, @deaths_residence], location_id: data.location_id]
      |> MonthlySARSCases.list_by()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_monthly_consolidation/2)
      |> put_new_data(:monthly_incidence, [])
      |> put_new_data(:monthly_deaths, [])
    else
      data
    end
  end

  defp fetch_monthly_consolidation({context, consolidation}, data) do
    case context do
      @cases_residence -> put_data(consolidation, :monthly_incidence, data)
      @deaths_residence -> put_data(consolidation, :monthly_deaths, data)
    end
  end

  @weekly_consolidations_keys [:location_id]

  defp fetch_weekly_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @weekly_consolidations_keys) do
      [contexts: [@cases_residence, @deaths_residence], location_id: data.location_id]
      |> WeeklySARSCases.list_by()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_weekly_consolidation/2)
      |> put_new_data(:weekly_incidence, [])
      |> put_new_data(:weekly_deaths, [])
    else
      data
    end
  end

  defp fetch_weekly_consolidation({context, consolidation}, data) do
    case context do
      @cases_residence -> put_data(consolidation, :weekly_incidence, data)
      @deaths_residence -> put_data(consolidation, :weekly_deaths, data)
    end
  end

  @daily_consolidations_keys [:location_id]

  defp fetch_daily_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @daily_consolidations_keys) do
      [contexts: @contexts, location_id: data.location_id]
      |> DailySARSCases.list_by()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_daily_consolidation/2)
      |> put_new_data(:daily_incidence, [])
      |> put_new_data(:daily_deaths, [])
      |> put_new_data(:daily_hospitalizations, [])
    else
      data
    end
  end

  defp fetch_daily_consolidation({context, consolidation}, data) do
    case context do
      @cases_residence -> put_data(consolidation, :daily_incidence, data)
      @deaths_residence -> put_data(consolidation, :daily_deaths, data)
      @hospitalizations_residence -> put_data(consolidation, :daily_hospitalizations, data)
    end
  end

  @day_states_consolidations_keys [:date, :states_ids]

  defp fetch_day_states_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_states_consolidations_keys) do
      [contexts: @contexts, locations_ids: data.states_ids, date: data.date]
      |> DailySARSCases.list_by()
      |> DailySARSCases.preload()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_day_states_consolidation/2)
      |> put_new_data(:day_states_incidence, [])
      |> put_new_data(:day_states_deaths, [])
      |> put_new_data(:day_states_hospitalizations, [])
    else
      data
    end
  end

  defp fetch_day_states_consolidation({context, consolidation}, data) do
    case context do
      @cases_residence ->
        consolidation
        |> Enum.map(&extract_states_incidence/1)
        |> put_data(:day_states_incidence, data)

      @deaths_residence ->
        consolidation
        |> Enum.map(&extract_states_deaths/1)
        |> put_data(:day_states_deaths, data)

      @hospitalizations_residence ->
        consolidation
        |> Enum.map(&extract_states_hospitalizations/1)
        |> put_data(:day_states_hospitalizations, data)
    end
  end

  @day_cities_consolidations_keys [:date, :cities_ids]

  defp fetch_day_cities_consolidations(%{changed_filters: changes, day_states_incidence: states_incidence} = data) do
    if DataManager.filters_changed?(changes, @day_cities_consolidations_keys) do
      [contexts: @contexts, locations_ids: data.cities_ids, date: data.date]
      |> DailySARSCases.list_by()
      |> DailySARSCases.preload()
      |> Enum.group_by(& &1.context)
      |> Enum.reduce(data, &fetch_day_cities_consolidation(&1, &2, states_incidence))
      |> put_new_data(:day_cities_incidence, [])
      |> put_new_data(:day_cities_deaths, [])
      |> put_new_data(:day_cities_hospitalizations, [])
    else
      data
    end
  end

  defp fetch_day_cities_consolidation({context, consolidation}, data, states_incidence) do
    case context do
      @cases_residence ->
        consolidation
        |> Enum.map(&extract_cities_incidence(&1, states_incidence))
        |> put_data(:day_cities_incidence, data)

      @deaths_residence ->
        consolidation
        |> Enum.map(&extract_cities_deaths(&1, states_incidence))
        |> put_data(:day_cities_deaths, data)

      @hospitalizations_residence ->
        consolidation
        |> Enum.map(&extract_cities_hospitalizations(&1, states_incidence))
        |> put_data(:day_cities_hospitalizations, data)
    end
  end

  @day_consolidations_keys [:location_id, :date]

  defp fetch_day_consolidations(%{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @day_consolidations_keys) do
      [contexts: @contexts, location_id: data.location_id, date: data.date]
      |> DailySARSCases.list_by()
      |> Enum.reduce(data, &fetch_day_consolidation/2)
      |> put_new_data_lazy(:day_incidence, &PandemicSARSCases.new/0)
      |> put_new_data_lazy(:day_deaths, &PandemicSARSCases.new/0)
      |> put_new_data_lazy(:day_hospitalizations, &PandemicSARSCases.new/0)
    else
      data
    end
  end

  defp fetch_day_consolidation(%{context: context} = cases, data) do
    case context do
      @cases_residence -> put_data(cases, :day_incidence, data)
      @deaths_residence -> put_data(cases, :day_deaths, data)
      @hospitalizations_residence -> put_data(cases, :day_hospitalizations, data)
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

  defp put_new_data(data, key, value) do
    if Map.has_key?(data, key) do
      Map.update!(data, :changed_filters, &DataManager.add_filter_change(&1, key))
    else
      put_data(value, key, data)
    end
  end

  defp put_new_data_lazy(data, key, function) do
    if Map.has_key?(data, key) do
      Map.update!(data, :changed_filters, &DataManager.add_filter_change(&1, key))
    else
      put_data(function.(), key, data)
    end
  end
end
