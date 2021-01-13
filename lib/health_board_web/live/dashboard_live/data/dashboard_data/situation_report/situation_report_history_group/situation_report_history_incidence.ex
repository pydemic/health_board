defmodule HealthBoardWeb.DashboardLive.SectionData.SituationReportHistoryIncidence do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [:index, :date, :daily_covid_reports, :weekly_covid_reports, :monthly_covid_reports]
  @data_keys [
    :date,
    :location_name,
    :daily_covid_reports,
    :weekly_covid_reports,
    :monthly_covid_reports,
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
