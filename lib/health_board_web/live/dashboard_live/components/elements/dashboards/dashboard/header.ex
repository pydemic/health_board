defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Header do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop groups, :list, required: true
  prop group_index, :integer, required: true
  prop params, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <header class="lg:px-10 sm:px-6 px-4 w-full bg-indigo-500 divide-y divide-white">
      <div class="justify-between items-center flex">
        <div class="text-white py-5 text-2xl font-bold">
          <h2>{{ @name }}</h2>
        </div>
      </div>

      <div class="text-white w-full py-5 justify-between items-center flex overflow-x-auto whitespace-nowrap">
        <div :for.with_index={{ {%{child: group}, index} <- @groups }}>
          <Otherwise condition={{ index == @group_index }}>
            <span class="px-2 rounded-full bg-white text-indigo-500">
              {{ group.name }}
            </span>

            <template slot="otherwise">
              <button :on-click="redirect" phx-value-index={{ index }} type="button" class="px-2 rounded-full hover:bg-indigo-600 hover:text-white focus:outline-none focus:bg-indigo-600 focus:text-white">
                {{ group.name }}
              </button>
            </template>
          </Otherwise>
        </div>
      </div>
    </header>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("redirect", %{"index" => index}, socket) do
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, index))}
  end

  defp updated_route(%{assigns: %{params: params}} = socket, index) do
    Router.Helpers.dashboard_path(socket, :index, Map.merge(params, %{"refetch" => true, "group_index" => index}))
  end
end
