defmodule HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.DemographicSummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.DemographicDashboard.{
    BirthsCard,
    CrudeBirthRateCard,
    GenderRatioCard,
    PopulationCard
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
        <PopulationCard card={{ Enum.at(@section.cards, 0) }} />
        <GenderRatioCard card={{ Enum.at(@section.cards, 1) }} />
        <BirthsCard card={{ Enum.at(@section.cards, 2) }} />
        <CrudeBirthRateCard card={{ Enum.at(@section.cards, 3) }} />
      </Grid>
    </Section>
    """
  end
end
