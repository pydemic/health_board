defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.History.HistoryTests do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.{PositivityRateEpicurve, SamplesEpicurve}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <SamplesEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <PositivityRateEpicurve card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
