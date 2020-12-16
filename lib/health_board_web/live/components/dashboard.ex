defmodule HealthBoardWeb.LiveComponents.Dashboard do
  use Surface.LiveComponent

  alias HealthBoard.Contexts
  alias HealthBoardWeb.LiveComponents.{DashboardMenu, Filters, Section, SectionHeader, Tabs}
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

      <SectionHeader title={{ title(@dashboard.name, @filters) }} description={{ @dashboard.description }} />

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

  defp title(name, filters) do
    if Map.has_key?(filters, :morbidity_context) and filters[:id] == "morbidity" do
      "Painel de #{Contexts.morbidity_name(filters.morbidity_context)}"
    else
      name
    end
  rescue
    _error -> name
  end
end
