defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicTestCapacity do
  alias HealthBoardWeb.Helpers.Math

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
        test_capacity: Math.test_capacity(confirmed, confirmed + discarded)
      },
      last_record_date: data.last_record_date
    }
  end
end
