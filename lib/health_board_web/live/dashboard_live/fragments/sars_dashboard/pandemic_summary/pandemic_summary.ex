defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.PandemicSummary.PandemicSummary do
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
    SamplesCard,
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
        <SamplesCard card={{ Enum.at(@section.cards, 2) }} />
        <PositivityRateCard card={{ Enum.at(@section.cards, 3) }} />
        <TestCapacityCard card={{ Enum.at(@section.cards, 4) }} />
        <HospitalizationsCard card={{ Enum.at(@section.cards, 5) }} />
        <HospitalizationRateCard card={{ Enum.at(@section.cards, 6) }} />
        <DeathsCard card={{ Enum.at(@section.cards, 7) }} />
        <DeathRateCard card={{ Enum.at(@section.cards, 8) }} />
        <FatalityRateCard card={{ Enum.at(@section.cards, 9) }} />
        <HospitalizationFatalityRateCard card={{ Enum.at(@section.cards, 10) }} />
      </Grid>
    </Section>
    """
  end
end
