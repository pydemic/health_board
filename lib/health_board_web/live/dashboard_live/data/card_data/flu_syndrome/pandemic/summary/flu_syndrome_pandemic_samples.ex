defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicSamples do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{confirmed: confirmed, discarded: discarded} = data.incidence

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        confirmed: confirmed,
        discarded: discarded,
        samples: confirmed + discarded
      },
      last_record_date: data.last_record_date
    }
  end
end
