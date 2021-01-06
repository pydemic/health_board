defmodule HealthBoardWeb.DashboardLive.SectionData.FluSyndromePandemicMaps do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [:index, :cities_incidence, :year_cities_population, :location_id]
  @data_keys [:cities_incidence, :year_cities_population, :location]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
