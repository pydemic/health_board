defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.PandemicSummary do
  use Surface.Component

  alias __MODULE__.{PandemicCitiesRankings, PandemicMaps, PandemicStatesRankings, PandemicSummary}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <PandemicSummary section={{ Enum.at(@group.sections, 0) }} />
      <PandemicMaps section={{ Enum.at(@group.sections, 1) }} />
      <PandemicStatesRankings section={{ Enum.at(@group.sections, 2) }} />
      <PandemicCitiesRankings section={{ Enum.at(@group.sections, 3) }} />
    </div>
    """
  end
end
