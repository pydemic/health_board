defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicCitiesFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    incidences = data.cities_incidence

    data.cities_deaths
    |> Enum.map(&fetch_fatality_rate(&1, incidences))
    |> Enum.sort(&(&1.fatality_rate >= &2.fatality_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_fatality_rate(city_deaths, incidences) do
    %{confirmed: deaths, location_id: location_id} = city_deaths
    %{confirmed: incidence} = Enum.find(incidences, %{confirmed: 0}, &(&1.location_id == location_id))

    %{
      name: city_deaths.location_name,
      fatality_rate: Math.fatality_rate(deaths, incidence)
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