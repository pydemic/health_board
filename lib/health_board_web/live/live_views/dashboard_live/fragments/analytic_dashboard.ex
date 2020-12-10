defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.AnalyticGroup
  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop index, :integer, default: 0

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <AnalyticGroup
      :for={{ group <- @dashboard.groups }}
      show={{ group.index == @index }}
      group={{ group }}
    />
    """
  end
end
