defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.History.HistoryTestCapacity do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.TestCapacityEpicurve
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <TestCapacityEpicurve card={{ Enum.at(@section.cards, 0) }} />
      </Grid>
    </Section>
    """
  end
end
