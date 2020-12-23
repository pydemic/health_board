defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.SarsRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.{
    DeathRateRanking,
    DeathsRanking,
    FatalityRateRanking,
    HospitalizationFatalityRateRanking,
    HospitalizationRateRanking,
    HospitalizationsRanking,
    IncidenceRanking,
    IncidenceRateRanking,
    PositivityRateRanking
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
        <IncidenceRanking card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRateRanking card={{ Enum.at(@section.cards, 1) }} />
        <PositivityRateRanking card={{ Enum.at(@section.cards, 2) }} />
        <HospitalizationsRanking card={{ Enum.at(@section.cards, 3) }} />
        <HospitalizationRateRanking card={{ Enum.at(@section.cards, 4) }} />
        <DeathsRanking card={{ Enum.at(@section.cards, 5) }} />
        <DeathRateRanking card={{ Enum.at(@section.cards, 6) }} />
        <FatalityRateRanking card={{ Enum.at(@section.cards, 7) }} />
        <HospitalizationFatalityRateRanking card={{ Enum.at(@section.cards, 8) }} />
      </Grid>
    </Section>
    """
  end
end
