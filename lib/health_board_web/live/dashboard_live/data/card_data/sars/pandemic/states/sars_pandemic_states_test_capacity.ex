defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicStatesTestCapacity do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    data.states_incidence
    |> Enum.sort(&(&1.test_capacity >= &2.test_capacity))
    |> Enum.take(10)
    |> Enum.map(&%{name: &1.location_name, test_capacity: &1.test_capacity})
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