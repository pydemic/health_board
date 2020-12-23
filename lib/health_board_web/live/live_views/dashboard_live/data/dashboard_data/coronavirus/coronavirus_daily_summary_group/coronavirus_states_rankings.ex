defmodule HealthBoardWeb.DashboardLive.SectionData.CoronavirusStatesRankings do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys []

  @data_keys []

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
