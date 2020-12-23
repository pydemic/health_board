defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusRankings do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    DeathRateRanking,
    DeathsRanking,
    FatalityRateRanking,
    IcuRateRanking,
    IncidenceRanking,
    IncidenceRateRanking
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
        <DeathsRanking card={{ Enum.at(@section.cards, 2) }} />
        <DeathRateRanking card={{ Enum.at(@section.cards, 3) }} />
        <FatalityRateRanking card={{ Enum.at(@section.cards, 4) }} />
        <IcuRateRanking card={{ Enum.at(@section.cards, 5) }} />
      </Grid>
    </Section>
    """
  end
end
