defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.MorbiditySummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard.{
    MorbidityDeathRateCard,
    MorbidityDeathsCard,
    MorbidityIncidenceCard,
    MorbidityIncidenceRateCard
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
        <MorbidityIncidenceCard card={{ Enum.at(@section.cards, 0) }} />
        <MorbidityIncidenceRateCard card={{ Enum.at(@section.cards, 1) }} />
        <MorbidityDeathsCard card={{ Enum.at(@section.cards, 2) }} />
        <MorbidityDeathRateCard card={{ Enum.at(@section.cards, 3) }} />
      </Grid>
    </Section>
    """
  end
end
