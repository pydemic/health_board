defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Summary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard
  alias HealthBoardWeb.LiveComponents.{DataSection, Grid}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataSection id={{ @section.id }} section={{ @section }} :let={{ data: data }}>
      <Grid>
        <IncidenceCard
          :for={{ section_card <- sort(@section.cards, data) }}
          card={{ section_card }}
        />
      </Grid>
    </DataSection>
    """
  end

  defp sort(section_cards, indexes) do
    if Enum.any?(indexes) do
      Enum.map(indexes, &Enum.at(section_cards, &1))
    else
      section_cards
    end
  end
end
