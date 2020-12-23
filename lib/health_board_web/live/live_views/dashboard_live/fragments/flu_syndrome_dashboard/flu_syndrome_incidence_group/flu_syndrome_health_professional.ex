defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromeHealthProfessional do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    HealthProfessionalIncidenceEpicurve,
    HealthProfessionalIncidenceMap
  }

  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <HealthProfessionalIncidenceEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <HealthProfessionalIncidenceMap card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
