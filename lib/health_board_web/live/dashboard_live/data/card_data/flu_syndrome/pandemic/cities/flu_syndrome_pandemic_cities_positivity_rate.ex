defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicCitiesPositivityRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.cities_incidence
    |> Enum.sort(&(&1.positivity_rate >= &2.positivity_rate))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, positivity_rate: &1.positivity_rate})
    |> wrap_result(data)
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
