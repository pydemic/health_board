defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicCitiesHospitalizationFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    cities_hospitalizations = data.cities_hospitalizations

    data.cities_deaths
    |> Enum.map(&fetch_hospitalization_fatality_rate(&1, cities_hospitalizations))
    |> Enum.sort(&(&1.hospitalization_fatality_rate >= &2.hospitalization_fatality_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_hospitalization_fatality_rate(city_deaths, cities_hospitalizations) do
    %{confirmed: deaths, location_id: location_id} = city_deaths

    %{confirmed: hospitalizations} =
      Enum.find(cities_hospitalizations, %{confirmed: 0}, &(&1.location_id == location_id))

    %{
      name: city_deaths.location_name,
      hospitalization_fatality_rate: Math.hospitalization_fatality_rate(deaths, hospitalizations)
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
