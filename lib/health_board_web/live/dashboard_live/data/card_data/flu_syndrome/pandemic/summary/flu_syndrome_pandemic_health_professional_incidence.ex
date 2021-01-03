defmodule HealthBoardWeb.DashboardLive.CardData.FluSyndromePandemicHealthProfessionalIncidence do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{health_professional_incidence: data.incidence.health_professional}
    }
  end
end
