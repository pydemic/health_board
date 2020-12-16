defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.MorbidityGroup
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <MorbidityGroup group={{ Enum.at(@dashboard.groups, 0) }}/>
    """
  end
end
