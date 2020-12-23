defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusDeathsGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusDeathsSection

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <CoronavirusDeathsSection section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end
