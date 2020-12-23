defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromeIncidenceGroup do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    FluSyndromeHealthProfessional,
    FluSyndromeIncidenceSection,
    FluSyndromePositivityRate
  }

  alias Phoenix.LiveView

  prop group, :map, required: true
  prop show, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div :show={{ @show }}>
      <FluSyndromeIncidenceSection section={{ Enum.at(@group.sections, 0) }} />
      <FluSyndromeHealthProfessional section={{ Enum.at(@group.sections, 1) }} />
      <FluSyndromePositivityRate section={{ Enum.at(@group.sections, 2) }} />
    </div>
    """
  end
end