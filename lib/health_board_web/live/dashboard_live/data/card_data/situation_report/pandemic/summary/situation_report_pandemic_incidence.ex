defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{incidence: data.covid_reports.cases},
      last_record_date: data.last_record_date
    }
  end
end
