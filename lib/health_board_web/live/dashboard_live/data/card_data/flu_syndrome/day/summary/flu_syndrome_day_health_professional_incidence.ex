defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromeDayHealthProfessionalIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{health_professional_incidence: data.day_incidence.health_professional},
      last_record_date: data.last_record_date
    }
  end
end
