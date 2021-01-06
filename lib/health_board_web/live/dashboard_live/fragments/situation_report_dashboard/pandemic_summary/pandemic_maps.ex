defmodule HealthBoardWeb.DashboardLive.Fragments.SituationReportDashboard.PandemicSummary.PandemicMaps do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.{DeathRateMap, IncidenceRateMap}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidenceRateMap card={{ Enum.at(@section.cards, 0) }} />
        <DeathRateMap card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
