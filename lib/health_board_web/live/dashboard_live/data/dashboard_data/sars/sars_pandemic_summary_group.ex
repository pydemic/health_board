defmodule HealthBoardWeb.DashboardLive.GroupData.SarsPandemicSummaryGroup do
  alias HealthBoardWeb.DashboardLive.{DataManager, SectionData}

  @changes_keys [
    :index,
    :incidence,
    :cities_incidence,
    :states_incidence,
    :deaths,
    :cities_deaths,
    :states_deaths,
    :hospitalizations,
    :cities_hospitalizations,
    :states_hospitalizations,
    :symptoms,
    :year_cities_population,
    :year_states_population,
    :year_population
  ]

  @data_keys [
    :changed_filters,
    :date,
    :location,
    :location_name,
    :incidence,
    :cities_incidence,
    :states_incidence,
    :deaths,
    :cities_deaths,
    :states_deaths,
    :hospitalizations,
    :cities_hospitalizations,
    :states_hospitalizations,
    :symptoms,
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
