defmodule HealthBoardWeb.DashboardLive.SectionData.DemographicSummary do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :year,
    :location_id,
    :year_births,
    :year_population
  ]

  @data_keys [
    :year,
    :year_births,
    :year_population,
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
