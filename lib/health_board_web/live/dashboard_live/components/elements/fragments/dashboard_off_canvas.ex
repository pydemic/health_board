defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.DashboardOffCanvas do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.OffCanvas
  alias Phoenix.LiveView

  prop other_dashboards, :list, required: true
  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
      <OffCanvas
        id="{{ @dashboard.id }}-dashboard"
        title={{ @dashboard.name }}>
        <template slot="body">
          <hr class="solid my-4"/>
          <span>
            <ul>
              <div class="my-2" :for={{ tab <- @dashboard.children }}>
                <li> <a> {{ tab.child.name }} </a> </li>
                <ul>
                  <div class="mx-2 my-2" :for={{ section <- tab.child.children }}>
                    <li> <a> {{ section.child.name }} </a> </li>
                    <ul>
                      <div class="mx-4 my-2" :for={{ indicators <- section.child.children }}>
                        <li> <a> {{ indicators.child.name }} </a> </li>
                      </div>
                    </ul>
                  </div>
                </ul>
              </div>
            </ul>
          </span>
          <hr class="solid my-4">
          <span :if={{ Enum.any?(@other_dashboards) }}>
            <hr class="solid my-4"/>
            OUTROS PAINÉIS
            <div class="my-2" :for={{ other_dashboard <- @other_dashboards }}>
              <a href="/{{ other_dashboard.id }}"> {{ other_dashboard.name }} </a>
            </div>
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
