defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.DailySummary.DailyStatesRankings do
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
        <PositivityRateRanking card={{ Enum.at(@section.cards, 2) }} />
        <TestCapacityRanking card={{ Enum.at(@section.cards, 3) }} />
        <HospitalizationsRanking card={{ Enum.at(@section.cards, 4) }} />
        <HospitalizationRateRanking card={{ Enum.at(@section.cards, 5) }} />
        <DeathsRanking card={{ Enum.at(@section.cards, 6) }} />
        <DeathRateRanking card={{ Enum.at(@section.cards, 7) }} />
        <FatalityRateRanking card={{ Enum.at(@section.cards, 8) }} />
        <HospitalizationFatalityRateRanking card={{ Enum.at(@section.cards, 9) }} />
      </Grid>
    </Section>
    """
  end
end
