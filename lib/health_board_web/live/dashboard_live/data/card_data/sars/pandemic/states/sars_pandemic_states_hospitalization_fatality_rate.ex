defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicStatesHospitalizationFatalityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    states_hospitalizations = data.states_hospitalizations

    data.states_deaths
    |> Enum.map(&fetch_hospitalization_fatality_rate(&1, states_hospitalizations))
    |> Enum.sort(&(&1.hospitalization_fatality_rate >= &2.hospitalization_fatality_rate))
    |> Enum.take(10)
    |> wrap_result(data)
  end

  defp fetch_hospitalization_fatality_rate(state_deaths, states_hospitalizations) do
    %{confirmed: deaths, location_id: location_id} = state_deaths

    %{confirmed: hospitalizations} =
      Enum.find(states_hospitalizations, %{confirmed: 0}, &(&1.location_id == location_id))

    %{
      name: state_deaths.location_name,
      hospitalization_fatality_rate: Math.hospitalization_fatality_rate(deaths, hospitalizations)
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
