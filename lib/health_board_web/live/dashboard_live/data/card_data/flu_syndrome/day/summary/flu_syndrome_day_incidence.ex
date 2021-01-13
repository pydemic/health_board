defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeDayIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{incidence: data.day_incidence.confirmed},
      last_record_date: data.last_record_date
    }
  end
end
