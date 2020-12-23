defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeCitiesIncidenceRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_cities_population

    data.day_cities_cases
    |> Enum.map(&fetch_incidence_rate(&1, populations))
    |> Enum.sort(&(&1.incidence_rate >= &2.incidence_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_incidence_rate(%{confirmed: incidence, location_id: location_id} = day_cases, populations) do
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))
    %{location: day_cases.location_name, incidence_rate: calculate_incidence_rate(incidence, population)}
  end

  defp calculate_incidence_rate(incidence, population) do
    if incidence > 0 and population > 0 do
      incidence * 100_000 / population
    else
      0.0
    end
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "Município"
      },
      result: %{
        ranking: ranking
      }
    }
  end
end
