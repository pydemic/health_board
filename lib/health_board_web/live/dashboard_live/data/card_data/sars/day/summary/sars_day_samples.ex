defmodule HealthBoardWeb.DashboardLive.CardData.SarsDaySamples do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        samples: data.day_incidence.samples
      },
      last_record_date: data.last_record_date
    }
  end
end
