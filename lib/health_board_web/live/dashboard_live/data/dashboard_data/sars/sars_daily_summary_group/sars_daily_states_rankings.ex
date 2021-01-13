defmodule HealthBoardWeb.DashboardLive.SectionData.SarsDailyStatesRankings do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :day_states_incidence,
    :day_states_deaths,
    :day_states_hospitalizations,
    :year_states_population
  ]

  @data_keys [
    :date,
    :day_states_incidence,
    :day_states_deaths,
    :day_states_hospitalizations,
    :year_states_population,
    :last_record_date
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
