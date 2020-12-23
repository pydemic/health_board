defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsDailySummaryGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    SarsDailySummarySection,
    SarsRankings
  }

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <SarsDailySummarySection section={{ Enum.at(@group.sections, 0) }} />
      <SarsRankings section={{ Enum.at(@group.sections, 1) }} />
      <SarsRankings section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
