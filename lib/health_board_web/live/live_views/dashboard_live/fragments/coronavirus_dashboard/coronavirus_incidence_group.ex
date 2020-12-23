defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusIncidenceGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusIncidenceSection

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <CoronavirusIncidenceSection section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end
