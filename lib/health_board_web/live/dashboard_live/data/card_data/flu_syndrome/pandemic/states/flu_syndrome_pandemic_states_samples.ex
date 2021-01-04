defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicStatesSamples do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.states_incidence
    |> Enum.sort(&(&1.samples >= &2.samples))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, samples: &1.samples})
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
