defmodule HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.FluSyndromePositivityRate do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.FluSyndromeDashboard.{
    PositivityRateEpicurve,
    PositivityRateMap
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
        <PositivityRateEpicurve card={{ Enum.at(@section.cards, 0) }} />
        <PositivityRateMap card={{ Enum.at(@section.cards, 1) }} />
      </Grid>
    </Section>
    """
  end
end
