defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeIncidenceRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{day_cases: %{confirmed: incidence}, year_population: %{total: population}} = data

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        incidence_rate: calculate_incidence_rate(incidence, population),
        incidence: incidence,
        population: population
      }
    }
  end

  defp calculate_incidence_rate(incidence, population) do
    if incidence > 0 and population > 0 do
      incidence * 100_000 / population
    else
      0.0
    end
  end
end
