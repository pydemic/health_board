defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.Summary do
  use Surface.Component

  alias __MODULE__.Summary
  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <Summary section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end