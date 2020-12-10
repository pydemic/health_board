defmodule HealthBoardWeb.DashboardLive.SectionData.WeeklyAnalyticHistory do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :from_year,
    :to_year,
    :location_id,
    :yearly_deaths_per_context,
    :yearly_morbidities_per_context,
    :yearly_population
  ]

  @data_keys [
    :from_year,
    :to_year,
    :yearly_deaths_per_context,
    :yearly_morbidities_per_context,
    :yearly_population,
    :location_name
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
