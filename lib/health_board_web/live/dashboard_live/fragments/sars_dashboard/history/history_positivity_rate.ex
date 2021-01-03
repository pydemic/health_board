defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.History.HistoryPositivityRate do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Components.{Grid, Section, SubSectionHeader}
  alias HealthBoardWeb.DashboardLive.Fragments.PositivityRateEpicurve
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />
      <Grid>
        <PositivityRateEpicurve card={{ Enum.at(@section.cards, 0) }} />
      </Grid>
    </Section>
    """
  end
end
