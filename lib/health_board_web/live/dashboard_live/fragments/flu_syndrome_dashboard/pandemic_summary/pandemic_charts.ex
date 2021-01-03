defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.PandemicSummary.PandemicCharts do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.{IncidencePerAgeGender, IncidenceRatePerAgeGender}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <IncidencePerAgeGender card={{ Enum.at(@section.cards, 0) }} />
        <IncidenceRatePerAgeGender card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
