defmodule HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.CoronavirusDeathsSection do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.CoronavirusDashboard.{
    DeathRateMap,
    DeathsEpicurve,
    DeathsPerMonth,
    DeathsPerWeek,
    PandemicDeathsMap
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
        <DeathsEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <DeathsPerMonth card={{ Enum.at(@section.cards, 1) }} />
        <DeathsPerWeek card={{ Enum.at(@section.cards, 2) }} />
        <DeathRateMap card={{ Enum.at(@section.cards, 3) }} />
        <PandemicDeathsMap card={{ Enum.at(@section.cards, 4) }} />
      </Grid>
    </Section>
    """
  end
end
