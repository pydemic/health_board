defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{incidence: data.day_incidence.confirmed}
    }
  end
end
