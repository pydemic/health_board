defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsDeathsGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsDeathsSection

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <SarsDeathsSection section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end