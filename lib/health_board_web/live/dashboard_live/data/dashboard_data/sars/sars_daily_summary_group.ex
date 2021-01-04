defmodule HealthBoardWeb.DashboardLive.GroupData.SarsDailySummaryGroup do
  alias HealthBoardWeb.DashboardLive.{DataManager, SectionData}

  @changes_keys [
    :index,
    :day_incidence,
    :day_cities_incidence,
    :day_states_incidence,
    :day_deaths,
    :day_cities_deaths,
    :day_states_deaths,
    :day_hospitalizations,
    :day_cities_hospitalizations,
    :day_states_hospitalizations,
    :year_cities_population,
    :year_states_population,
    :year_population
  ]

  @data_keys [
    :changed_filters,
    :date,
    :location_name,
    :day_incidence,
    :day_cities_incidence,
    :day_states_incidence,
    :day_deaths,
    :day_cities_deaths,
    :day_states_deaths,
    :day_hospitalizations,
    :day_cities_hospitalizations,
    :day_states_hospitalizations,
    :year_cities_population,
    :year_states_population,
    :year_population
  ]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, group, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(group.sections, &SectionData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
