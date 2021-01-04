defmodule HealthBoardWeb.DashboardLive.CardData.SarsDayHospitalizations do
  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    %{
      filters: %{
        date: data.date,
        location: data.location_name
      },
      result: %{hospitalizations: data.day_hospitalizations.confirmed}
    }
  end
end
