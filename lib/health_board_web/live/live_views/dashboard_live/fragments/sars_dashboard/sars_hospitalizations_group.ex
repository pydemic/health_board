defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsHospitalizationsGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsHospitalizationsSection

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <SarsHospitalizationsSection section={{ Enum.at(@group.sections, 0) }} />
    </div>
    """
  end
end
