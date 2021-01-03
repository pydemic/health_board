defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.DailySummary.DailyStatesRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathRateRanking,
    DeathsRanking,
    FatalityRateRanking,
    IncidenceRanking,
    IncidenceRateRanking
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
        <DeathsRanking card={{ Enum.at(@section.cards, 2) }} />
        <DeathRateRanking card={{ Enum.at(@section.cards, 3) }} />
        <FatalityRateRanking card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
