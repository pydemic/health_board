defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.MorbidityIncidence do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.{
    IncidencePerAgeGender,
    IncidencePerRace,
    IncidenceRateControlDiagram,
    IncidenceRateMap,
    IncidenceRatePerYear
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
        <IncidenceRateMap card={{ Enum.at(@section.cards, 0) }} />
        <Grid wrap={{ true }} width_l={{ 2 }} width_m={{ 1 }}>
          <IncidencePerAgeGender card={{ Enum.at(@section.cards, 1) }} />
          <IncidencePerRace card={{ Enum.at(@section.cards, 2) }} />
        </Grid>
        <IncidenceRatePerYear card={{ Enum.at(@section.cards, 3) }} />
        <IncidenceRateControlDiagram card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
