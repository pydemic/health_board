defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicSamples do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        samples: data.incidence.samples
      }
    }
  end
end
