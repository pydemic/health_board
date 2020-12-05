defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.ImmediateSummary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SubSectionHeader title={{ @section.name }} description={{ @section.description }} />

      <Grid>
        <IncidenceCard
          :for={{ {_id, card} <- @section.cards }}
          card={{ card }}
        />
      </Grid>
    </Section>
    """
  end
end
