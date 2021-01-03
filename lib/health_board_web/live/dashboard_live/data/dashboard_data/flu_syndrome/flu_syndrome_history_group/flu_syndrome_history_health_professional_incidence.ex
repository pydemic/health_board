defmodule HealthBoardWeb.DashboardLive.SectionData.FluSyndromeHistoryHealthProfessionalIncidence do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [:index, :date, :daily_incidence]
  @data_keys [:date, :location_name, :daily_incidence]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
