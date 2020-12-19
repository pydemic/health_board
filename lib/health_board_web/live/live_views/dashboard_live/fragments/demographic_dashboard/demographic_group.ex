defmodule HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.DemographicGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.{
    DemographicPopulation,
    DemographicSummary
  }

  alias Phoenix.LiveView

  prop group, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <DemographicSummary section={{ Enum.at(@group.sections, 0) }} />
      <DemographicPopulation section={{ Enum.at(@group.sections, 1) }} />
    </div>
    """
  end
end