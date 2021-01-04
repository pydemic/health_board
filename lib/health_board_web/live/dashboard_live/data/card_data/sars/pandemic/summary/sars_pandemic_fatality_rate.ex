defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{deaths: %{confirmed: deaths}, incidence: %{confirmed: incidence}} = data

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
