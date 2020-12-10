defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.AnalyticGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.{History, Region, Summary}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <Summary section={{ Enum.at @group.sections, 0 }} />
      <History section={{ Enum.at @group.sections, 1 }} />
      <Region section={{ Enum.at @group.sections, 2 }} />
    </div>
    """
  end
end
