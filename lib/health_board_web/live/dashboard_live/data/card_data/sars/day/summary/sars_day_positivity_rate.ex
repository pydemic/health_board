defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayPositivityRate do
  alias HealthBoardWeb.Helpers.Math

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{confirmed: confirmed, samples: samples} = data.day_incidence

    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{
        confirmed: confirmed,
        samples: samples,
        positivity_rate: Math.positivity_rate(confirmed, samples)
      },
      last_record_date: data.last_record_date
    }
  end
end
