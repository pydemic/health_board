defmodule HealthBoardWeb.DashboardLive.CardData.SituationReportPandemicDeathRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{covid_reports: %{deaths: deaths}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        death_rate: Math.death_rate(deaths, population),
        deaths: deaths,
        population: population
      }
    }
  end
end
