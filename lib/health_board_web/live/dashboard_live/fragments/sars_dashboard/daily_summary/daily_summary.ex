defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.DailySummary.DailySummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathRateCard,
    DeathsCard,
    FatalityRateCard,
    HospitalizationFatalityRateCard,
    HospitalizationRateCard,
    HospitalizationsCard,
    IncidenceCard,
    IncidenceRateCard,
    PositivityRateCard,
    TestCapacityCard
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
        <PositivityRateCard card={{ Enum.at(@section.cards, 2) }} />
        <TestCapacityCard card={{ Enum.at(@section.cards, 3) }} />
        <HospitalizationsCard card={{ Enum.at(@section.cards, 4) }} />
        <HospitalizationRateCard card={{ Enum.at(@section.cards, 5) }} />
        <DeathsCard card={{ Enum.at(@section.cards, 6) }} />
        <DeathRateCard card={{ Enum.at(@section.cards, 7) }} />
        <FatalityRateCard card={{ Enum.at(@section.cards, 8) }} />
        <HospitalizationFatalityRateCard card={{ Enum.at(@section.cards, 9) }} />
      </Grid>
    </Section>
    """
  end
end
