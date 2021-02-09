defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.DashboardOffCanvas do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.OffCanvas
  alias Phoenix.LiveView

  prop dashboards, :list, required: true
  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <OffCanvas
        id="{{ @dashboard.id }}-dashboard"
        title={{ @dashboard.name }}>
        <template slot="body">
          <hr class="solid"/>
          <div :for={{ tab <- @dashboard.children }}>
            {{ tab.child.name }}
            <div :for={{ section <- tab.child.children }}>
              {{ section.child.name }}
              <div :for={{ indicators <- section.child.children }}>
                {{ indicators.child.name }}
              </div>
            </div>
            <hr class="solid">
          </div>
          <span :if={{ Enum.any?(@dashboards) }}>
            <hr class="solid"/>
            OUTROS PAINÉIS
          </span>
        </template>
        <template slot="open_button">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="inline w-7 h-7">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
          </svg>
        </template>
      </OffCanvas>

    """
  end
end
