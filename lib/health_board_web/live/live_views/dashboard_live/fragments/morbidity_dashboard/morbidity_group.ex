defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.MorbidityGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.{
    MorbidityDeaths,
    MorbidityIncidence,
    MorbiditySummary
  }

  alias Phoenix.LiveView

  prop group, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <MorbiditySummary section={{ Enum.at(@group.sections, 0) }} />
      <MorbidityIncidence section={{ Enum.at(@group.sections, 1) }} />
      <MorbidityDeaths section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end
