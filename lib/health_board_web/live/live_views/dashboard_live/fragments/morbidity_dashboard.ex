defmodule HealthBoardWeb.DashboardLive.Fragments.MorbidityDashboard do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Section, SectionHeader}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>
      <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />
    </Section>
    """
  end
end
