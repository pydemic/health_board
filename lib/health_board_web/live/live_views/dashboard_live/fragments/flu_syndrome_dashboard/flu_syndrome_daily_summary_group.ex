defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromeDailySummaryGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    FluSyndromeDailySummarySection,
    FluSyndromeRankings
  }

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <FluSyndromeDailySummarySection section={{ Enum.at(@group.sections, 0) }} />
      <FluSyndromeRankings section={{ Enum.at(@group.sections, 1) }} />
      <FluSyndromeRankings section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
