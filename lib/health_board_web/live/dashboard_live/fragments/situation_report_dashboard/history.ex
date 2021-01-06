defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.History do
  use Surface.Component

  alias __MODULE__.{HistoryDeaths, HistoryIncidence}
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <HistoryIncidence section={{ Enum.at(@group.sections, 0) }} />
      <HistoryDeaths section={{ Enum.at(@group.sections, 1) }} />
    </div>
    """
  end
end
