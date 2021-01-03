defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.History.HistoryHealthProfessionalIncidence do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.HealthProfessionalIncidenceEpicurve
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <HealthProfessionalIncidenceEpicurve card={{ Enum.at(@section.cards, 0) }} />
      </Grid>
    </Section>
    """
  end
end
