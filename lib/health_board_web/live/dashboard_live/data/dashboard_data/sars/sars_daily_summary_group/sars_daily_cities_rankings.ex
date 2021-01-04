defmodule HealthBoardWeb.DashboardLive.SectionData.SarsDailyCitiesRankings do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :day_cities_incidence,
    :day_cities_deaths,
    :day_cities_hospitalizations,
    :year_cities_population
  ]

  @data_keys [:date, :day_cities_incidence, :day_cities_deaths, :day_cities_hospitalizations, :year_cities_population]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
