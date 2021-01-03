defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.DailySummary do
  use Surface.Component

  alias __MODULE__.{DailyCitiesRankings, DailyStatesRankings, DailySummary}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <DailySummary section={{ Enum.at(@group.sections, 0) }} />
      <DailyStatesRankings section={{ Enum.at(@group.sections, 1) }} />
      <DailyCitiesRankings section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
