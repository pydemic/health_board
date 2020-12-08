defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.Summary do
  use Surface.Component

  alias HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.IncidenceCard
  alias HealthBoardWeb.LiveComponents.{Grid, Section, SubSectionHeader}
  alias Phoenix.LiveView

  prop section, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    section_cards =
      assigns.section.cards
      |> Enum.sort(&(elem(&1, 1).name <= elem(&2, 1).name))
      |> Enum.sort(&compare_severity/2)

    ~H"""
    <Section>
      <SubSectionHeader
        title={{ @section.name }}
        description={{ @section.description }}
      />

      <Grid>
        <IncidenceCard
          :for={{ {id, card} <- section_cards }}
          card_id={{ id }}
          card={{ card }}
        />
      </Grid>
    </Section>
    """
  end

  defp compare_severity({_key, %{data: %{overall_severity: s1}}}, {_key2, %{data: %{overall_severity: s2}}}) do
    case {s1, s2} do
      {:above_average, _s2} -> true
      {_s1, :above_average} -> false
      {:on_average, _s2} -> true
      {_s1, :on_average} -> false
      {:below_average, _s2} -> true
      {_s1, :below_average} -> false
      {_s1, _s2} -> true
    end
  end
end
