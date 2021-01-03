defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.DailySummary.DailySummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}

  alias HealthBoardWeb.DashboardLive.Fragments.{
    DeathRateCard,
    DeathsCard,
    FatalityRateCard,
    IncidenceCard,
    IncidenceRateCard
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
        <DeathsCard card={{ Enum.at(@section.cards, 2) }} />
        <DeathRateCard card={{ Enum.at(@section.cards, 3) }} />
        <FatalityRateCard card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
