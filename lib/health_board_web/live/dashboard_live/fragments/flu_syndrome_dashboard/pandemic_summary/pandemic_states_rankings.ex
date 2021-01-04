defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.PandemicSummary.PandemicStatesRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    HealthProfessionalIncidenceRanking,
    IncidenceRanking,
    IncidenceRateRanking,
    PositivityRateRanking,
    SamplesRanking
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
        <HealthProfessionalIncidenceRanking card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
