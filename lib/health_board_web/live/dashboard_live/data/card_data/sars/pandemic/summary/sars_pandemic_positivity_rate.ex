defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicPositivityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{confirmed: confirmed, samples: samples} = data.incidence

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        confirmed: confirmed,
        samples: samples,
        positivity_rate: Math.positivity_rate(confirmed, samples)
      }
    }
  end
end
