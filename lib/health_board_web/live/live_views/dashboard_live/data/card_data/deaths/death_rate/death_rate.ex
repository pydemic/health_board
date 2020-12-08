defmodule HealthBoardWeb.DashboardLive.CardData.DeathRate do
  alias HealthBoardWeb.DashboardLive.CardData.IncidenceRate

  @spec fetch(map) :: map
  def fetch(map) do
    IncidenceRate.fetch(map)
  end
end
