defmodule HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.DemographicBirths do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.{
    BirthsPerChildMass,
    BirthsPerMotherAgeGroup,
    BirthsPerYear,
    CrudeBirthRateMap,
    CrudeBirthRatePerYear
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
        <CrudeBirthRateMap card={{ Enum.at(@section.cards, 0) }} />

        <Grid wrap={{ true }} width_l={{ 2 }} width_m={{ 1 }}>
          <BirthsPerYear card={{ Enum.at(@section.cards, 1) }} />
          <CrudeBirthRatePerYear card={{ Enum.at(@section.cards, 2) }} />
        </Grid>

        <BirthsPerMotherAgeGroup card={{ Enum.at(@section.cards, 3) }} />
        <BirthsPerChildMass card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
