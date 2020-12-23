defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeCitiesPositivityRate do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.day_cities_cases
    |> Enum.sort(&(&1.positivity_rate >= &2.positivity_rate))
    |> Enum.take(10)
    |> Enum.map(&%{location: &1.location_name, positivity_rate: &1.positivity_rate})
    |> wrap_result(data)
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
