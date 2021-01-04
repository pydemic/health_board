defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicCitiesDeathRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_cities_population

    data.cities_deaths
    |> Enum.map(&fetch_death_rate(&1, populations))
    |> Enum.sort(&(&1.death_rate >= &2.death_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_death_rate(city_deaths, populations) do
    %{confirmed: deaths, location_id: location_id} = city_deaths
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))

    %{
      name: city_deaths.location_name,
      death_rate: Math.death_rate(deaths, population)
    }
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
