defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.History do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HistoryChart
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />

      <Grid>
        <HistoryChart
          :for={{ section_card <- @section.cards }}
          card={{ section_card }}
        />
      </Grid>
    </Section>
    """
  end
end
