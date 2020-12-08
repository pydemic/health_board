defmodule HealthBoardWeb.DashboardLive.CardData.Deaths do
  alias HealthBoardWeb.DashboardLive.CardData.Deaths

  @spec fetch(map) :: map
  def fetch(map) do
    Deaths.fetch(map)
  end
end
