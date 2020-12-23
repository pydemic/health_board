defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusDailySummaryGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    CoronavirusDailySummarySection,
    CoronavirusRankings
  }

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <CoronavirusDailySummarySection section={{ Enum.at(@group.sections, 0) }} />
      <CoronavirusRankings section={{ Enum.at(@group.sections, 1) }} />
      <CoronavirusRankings section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
