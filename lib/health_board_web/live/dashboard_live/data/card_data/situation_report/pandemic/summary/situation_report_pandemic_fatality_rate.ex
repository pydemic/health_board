defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{covid_reports: %{cases: incidence, deaths: deaths}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        fatality_rate: Math.fatality_rate(deaths, incidence),
        deaths: deaths,
        incidence: incidence
      }
    }
  end
end
