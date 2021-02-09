defmodule HealthBoardWeb.DashboardLive.Components.Dashboard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, DynamicElement}
  alias HealthBoardWeb.DashboardLive.Components.ElementsFragments.DashboardOffCanvas
  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    group_index = Map.get(assigns.params, :group_index, 0)
    %{child: group} = Enum.at(assigns.dashboard.children, group_index, %{child: nil})

    ~H"""
    <DataWrapper id={{ @dashboard.id }} :let={{ data: _data }}>
      <header class="lg:px-10 sm:px-6 px-4 w-full bg-indigo-500 divide-y divide-white">
        <div class="justify-between items-center flex">
          <div class="text-white py-5 text-2xl font-bold">
            <h2>
              {{ @dashboard.name }}
            </h2>
          </div>
          <div class="w-7 h-7">
            <DashboardOffCanvas dashboard={{ @dashboard }} dashboards={{ [] }}/>
          </div>
        </div>
        <div class="text-white w-full py-5 justify-between items-center flex overflow-x-auto whitespace-nowrap">
          <a
            :for.with_index={{ {%{child: group}, index} <- @dashboard.children }}
            href="/"
            class={{ "px-2", "rounded-full", "bg-white": group_index == index, "text-indigo-500": group_index == index }}>
            {{ group.name }}
          </a>
        </div>
      </header>

      <DynamicElement :if={{ not is_nil(group) }} element={{ group }} />
    </DataWrapper>
    """
  end
end
