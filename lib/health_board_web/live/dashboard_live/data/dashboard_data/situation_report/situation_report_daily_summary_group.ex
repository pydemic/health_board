defmodule HealthBoardWeb.DashboardLive.GroupData.SituationReportDailySummaryGroup do
  alias HealthBoardWeb.DashboardLive.{DataManager, SectionData}

  @changes_keys [
    :index,
    :day_covid_reports,
    :day_cities_covid_reports,
    :day_states_covid_reports,
    :year_cities_population,
    :year_states_population,
    :year_population
  ]

  @data_keys [
    :changed_filters,
    :date,
    :location_name,
    :day_covid_reports,
    :day_cities_covid_reports,
    :day_states_covid_reports,
    :year_cities_population,
    :year_states_population,
    :year_population,
    :last_record_date
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
