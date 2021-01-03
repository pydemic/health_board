defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicCitiesIncidenceRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_cities_population

    data.cities_incidence
    |> Enum.map(&fetch_incidence_rate(&1, populations))
    |> Enum.sort(&(&1.incidence_rate >= &2.incidence_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_incidence_rate(%{confirmed: incidence, location_id: location_id} = pandemic_incidence, populations) do
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))
    %{name: pandemic_incidence.location_name, incidence_rate: Math.incidence_rate(incidence, population)}
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "Estado"
      },
      result: %{
        ranking: ranking
      }
    }
  end
end
