defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.PandemicSummary do
  use Surface.Component

  alias __MODULE__.{PandemicCharts, PandemicCitiesRankings, PandemicMaps, PandemicStatesRankings, PandemicSummary}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <PandemicSummary section={{ Enum.at(@group.sections, 0) }} />
      <PandemicMaps section={{ Enum.at(@group.sections, 1) }} />
      <PandemicCharts section={{ Enum.at(@group.sections, 2) }} />
      <PandemicStatesRankings section={{ Enum.at(@group.sections, 3) }} />
      <PandemicCitiesRankings section={{ Enum.at(@group.sections, 4) }} />
    </div>
    """
  end
end
