defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Summary do
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
          :for={{ card <- Enum.sort(Map.values(@section.cards), &(&1.name <= &2.name)) }}
          card={{ card }}
        />
      </Grid>
    </Section>
    """
  end
end
