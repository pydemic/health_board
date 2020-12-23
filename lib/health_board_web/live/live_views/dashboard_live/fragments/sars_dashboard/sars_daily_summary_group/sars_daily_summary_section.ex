defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsDailySummarySection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    DeathRateCard,
    DeathsCard,
    FatalityRateCard,
    HospitalizationFatalityRateCard,
    HospitalizationRateCard,
    HospitalizationsCard,
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
        <HospitalizationsCard card={{ Enum.at(@section.cards, 3) }} />
        <HospitalizationRateCard card={{ Enum.at(@section.cards, 4) }} />
        <DeathsCard card={{ Enum.at(@section.cards, 5) }} />
        <DeathRateCard card={{ Enum.at(@section.cards, 6) }} />
        <FatalityRateCard card={{ Enum.at(@section.cards, 7) }} />
        <HospitalizationFatalityRateCard card={{ Enum.at(@section.cards, 8) }} />
      </Grid>
    </Section>
    """
  end
end
