defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.MorbidityDeaths do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.{
    DeathRateControlDiagram,
    DeathRateMap,
    DeathRatePerYear,
    DeathsPerAgeGender,
    DeathsPerRace
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
        <DeathRateMap card={{ Enum.at(@section.cards, 0) }} />
        <Grid wrap={{ true }} width_l={{ 2 }} width_m={{ 1 }}>
          <DeathsPerAgeGender card={{ Enum.at(@section.cards, 1) }} />
          <DeathsPerRace card={{ Enum.at(@section.cards, 2) }} />
        </Grid>
        <DeathRatePerYear card={{ Enum.at(@section.cards, 3) }} />
        <DeathRateControlDiagram card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
