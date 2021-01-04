defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_deaths: %{confirmed: deaths}, day_incidence: %{confirmed: incidence}} = data

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
