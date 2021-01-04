defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.DailySummary.DailyCitiesRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathRateRanking,
    DeathsRanking,
    FatalityRateRanking,
    HospitalizationFatalityRateRanking,
    HospitalizationRateRanking,
    HospitalizationsRanking,
    IncidenceRanking,
    IncidenceRateRanking,
    PositivityRateRanking,
    SamplesRanking,
    TestCapacityRanking
  }

  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidenceRanking card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRateRanking card={{ Enum.at(@section.cards, 1) }} />
        <SamplesRanking card={{ Enum.at(@section.cards, 2) }} />
        <PositivityRateRanking card={{ Enum.at(@section.cards, 3) }} />
        <TestCapacityRanking card={{ Enum.at(@section.cards, 4) }} />
        <HospitalizationsRanking card={{ Enum.at(@section.cards, 5) }} />
        <HospitalizationRateRanking card={{ Enum.at(@section.cards, 6) }} />
        <DeathsRanking card={{ Enum.at(@section.cards, 7) }} />
        <DeathRateRanking card={{ Enum.at(@section.cards, 8) }} />
        <FatalityRateRanking card={{ Enum.at(@section.cards, 9) }} />
        <HospitalizationFatalityRateRanking card={{ Enum.at(@section.cards, 10) }} />
      </Grid>
    </Section>
    """
  end
end
