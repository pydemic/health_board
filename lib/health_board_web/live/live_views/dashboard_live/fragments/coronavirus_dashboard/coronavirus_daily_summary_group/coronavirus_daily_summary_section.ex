defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusDailySummarySection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    DeathRateCard,
    DeathsCard,
    FatalityRateCard,
    IcuRateCard,
    IncidenceCard,
    IncidenceRateCard
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
        <IncidenceCard card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRateCard card={{ Enum.at(@section.cards, 1) }} />
        <IcuRateCard card={{ Enum.at(@section.cards, 2) }} />
        <DeathsCard card={{ Enum.at(@section.cards, 3) }} />
        <DeathRateCard card={{ Enum.at(@section.cards, 4) }} />
        <FatalityRateCard card={{ Enum.at(@section.cards, 5) }} />
      </Grid>
    </Section>
    """
  end
end
