defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicStatesHospitalizationRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    populations = data.year_states_population

    data.states_hospitalizations
    |> Enum.map(&fetch_hospitalization_rate(&1, populations))
    |> Enum.sort(&(&1.hospitalization_rate >= &2.hospitalization_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_hospitalization_rate(state_hospitalizations, populations) do
    %{confirmed: hospitalizations, location_id: location_id} = state_hospitalizations
    %{total: population} = Enum.find(populations, %{total: 0}, &(&1.location_id == location_id))

    %{
      name: state_hospitalizations.location_name,
      hospitalization_rate: Math.hospitalization_rate(hospitalizations, population)
    }
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
