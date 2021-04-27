defmodule HealthBoardWeb.DashboardLive.Components.CovidReports.Deaths do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.ChartCard
  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec daily_epicurve(map, map) :: LiveView.Rendered.t()
  def daily_epicurve(assigns, params) do
    ~H"""
    <ChartCard card={{ @element }} params={{ params }} />
    """
  end

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      Do not use this function.
    </div>
    """
  end
end
