defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeDayIncidenceRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_incidence: %{confirmed: incidence}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        incidence_rate: Math.incidence_rate(incidence, population),
        incidence: incidence,
        population: population
      }
    }
  end
end
