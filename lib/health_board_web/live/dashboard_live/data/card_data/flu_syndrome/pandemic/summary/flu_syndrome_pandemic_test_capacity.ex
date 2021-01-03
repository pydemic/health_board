defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicTestCapacity do
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
        test_capacity: Math.test_capacity(confirmed, discarded)
      }
    }
  end
end
