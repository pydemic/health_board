defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsIncidenceGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsIncidenceSection

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <SarsIncidenceSection section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end
