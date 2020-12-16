defmodule HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.DemographicPopulation do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.{
    PopulationGrowth,
    PopulationMap,
    PopulationPerAgeGroup
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
        <PopulationMap card={{ Enum.at(@section.cards, 0) }} />
        <Grid wrap={{ true }} width_l={{ 2 }} width_m={{ 1 }}>
          <PopulationGrowth card={{ Enum.at(@section.cards, 1) }} />
          <PopulationPerAgeGroup card={{ Enum.at(@section.cards, 2) }} />
        </Grid>
      </Grid>
    </Section>
    """
  end
end
