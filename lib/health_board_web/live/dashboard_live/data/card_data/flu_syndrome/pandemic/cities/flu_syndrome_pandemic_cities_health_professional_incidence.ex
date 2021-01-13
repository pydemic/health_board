defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicCitiesHealthProfessionalIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.cities_incidence
    |> Enum.sort(&(&1.health_professional >= &2.health_professional))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, health_professional_incidence: &1.health_professional})
    |> wrap_result(data)
  end

  defp wrap_result(ranking, data) do
    %{
      filters: %{
        date: data.date,
        locations_context: "UF"
      },
      result: %{
        ranking: ranking
      },
      last_record_date: data.last_record_date
    }
  end
end
