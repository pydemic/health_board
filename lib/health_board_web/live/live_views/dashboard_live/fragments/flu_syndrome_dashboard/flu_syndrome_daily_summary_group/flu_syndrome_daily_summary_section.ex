defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromeDailySummarySection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    IncidenceCard,
    IncidenceRateCard,
    PositivityRateCard
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
        <IncidenceCard card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRateCard card={{ Enum.at(@section.cards, 1) }} />
        <PositivityRateCard card={{ Enum.at(@section.cards, 2) }} />
      </Grid>
    </Section>
    """
  end
end
