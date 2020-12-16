defmodule HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.DemographicGroup
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DemographicGroup group={{ Enum.at(@dashboard.groups, 0) }}/>
    """
  end
end
