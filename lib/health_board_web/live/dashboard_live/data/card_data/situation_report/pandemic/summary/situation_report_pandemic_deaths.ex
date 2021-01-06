defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicDeaths do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{deaths: data.covid_reports.deaths}
    }
  end
end
