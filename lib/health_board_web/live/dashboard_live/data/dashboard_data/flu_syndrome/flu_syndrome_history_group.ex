defmodule HealthBoardWeb.DashboardLive.GroupData.FluSyndromeHistoryGroup do
  alias HealthBoardWeb.DashboardLive.{DataManager, SectionData}

  @changes_keys [
    :index,
    :date,
    :daily_incidence,
    :monthly_incidence,
    :weekly_incidence
  ]

  @data_keys [
    :changed_filters,
    :date,
    :location_name,
    :daily_incidence,
    :monthly_incidence,
    :weekly_incidence,
    :last_record_date
  ]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, group, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(group.sections, &SectionData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
