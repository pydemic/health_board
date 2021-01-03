defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.DailySummary.DailyCitiesRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    HealthProfessionalIncidenceRanking,
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
        <HealthProfessionalIncidenceRanking card={{ Enum.at(@section.cards, 2) }} />
        <PositivityRateRanking card={{ Enum.at(@section.cards, 3) }} />
        <TestCapacityRanking card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
