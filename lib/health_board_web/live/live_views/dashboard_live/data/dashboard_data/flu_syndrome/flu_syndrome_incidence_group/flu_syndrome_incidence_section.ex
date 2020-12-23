defmodule HealthBoardWeb.DashboardLive.SectionData.FluSyndromeIncidenceSection do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :daily_cases,
    :monthly_cases,
    :weekly_cases,
    :day_locations_cases,
    :day_cases,
    :pandemic_locations_cases,
    :week_case,
    :year_locations_population
  ]

  @data_keys [
    :changed_filters,
    :date,
    :from_year,
    :to_year,
    :from_date,
    :to_date,
    :locations_ids,
    :location_name,
    :locations_names,
    :daily_cases,
    :monthly_cases,
    :weekly_cases,
    :day_locations_cases,
    :day_cases,
    :pandemic_locations_cases,
    :week_case,
    :year_locations_population
  ]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
