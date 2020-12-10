defmodule HealthBoardWeb.DashboardLive.SectionData.ImmediateAnalyticRegion do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :index,
    :year,
    :location_id,
    :year_locations_contexts_deaths,
    :year_locations_contexts_morbidities,
    :year_locations_population
  ]

  @data_keys [
    :year,
    :locations,
    :locations_names,
    :year_locations_contexts_deaths,
    :year_locations_contexts_morbidities,
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
