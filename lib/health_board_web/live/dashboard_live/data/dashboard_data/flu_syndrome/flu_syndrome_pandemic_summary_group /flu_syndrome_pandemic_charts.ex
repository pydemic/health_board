defmodule HealthBoardWeb.DashboardLive.SectionData.FluSyndromePandemicCharts do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [:index, :incidence, :year_population]
  @data_keys [:incidence, :location_name, :year_population]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end