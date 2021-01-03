defmodule HealthBoardWeb.DashboardLive.Components.Dashboard do
  use Surface.LiveComponent

  alias HealthBoardWeb.DashboardLive.Components.{DashboardMenu, Filters, Section, SectionHeader, Tabs}
  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop filters, :map, required: true
  prop filters_options, :map, required: true

  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Section>

      <Filters id="filters" filters={{ @filters }} options={{ @filters_options }} />

      <SectionHeader title={{ @dashboard.name }} description={{ @dashboard.description }} />

      <Tabs
        :if={{ Enum.count(@dashboard.groups) > 1 }}
        index={{ @filters[:index] || 0 }}
        elements={{ @dashboard.groups }}
      />

      <slot />

      <DashboardMenu dashboard={{ @dashboard }} group_index={{ @filters[:index] || 0 }} />
    </Section>
    """
  end
end
