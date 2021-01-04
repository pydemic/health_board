defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.DailySummary.DailySummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    HealthProfessionalIncidenceCard,
    IncidenceCard,
    IncidenceRateCard,
    PositivityRateCard,
    SamplesCard
  }

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
        <HealthProfessionalIncidenceCard card={{ Enum.at(@section.cards, 2) }} />
        <SamplesCard card={{ Enum.at(@section.cards, 3) }} />
        <PositivityRateCard card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
