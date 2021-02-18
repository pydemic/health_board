defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Header do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.{Eye, EyeOff, Moon, Sun}
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop groups, :list, required: true
  prop group_index, :integer, required: true
  prop params, :map, required: true
  prop dark_mode, :boolean, required: true
  prop show_options, :boolean, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <header class="lg:px-10 sm:px-6 px-4 w-full divide-y divide-hb-ba dark:divide-hb-ba-dark bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
      <div class="flex justify-between items-center">
        <div class="py-5 text-2xl font-bold">
          <h2>{{ @name }}</h2>
        </div>

        <div class="flex-grow">
        </div>

        <button :on-click="toggle_options" class="py-5 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
          <Otherwise condition={{ @show_options }}>
            <EyeOff />

            <template slot="otherwise">
              <Eye />
            </template>
          </Otherwise>
        </button>

        <button :on-click="toggle_dark_mode" class="py-5 ml-2 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
          <Otherwise condition={{ @dark_mode }}>
            <Sun />

            <template slot="otherwise">
              <Moon />
            </template>
          </Otherwise>
        </button>
      </div>

      <div class="flex justify-between items-center py-5 w-full overflow-x-auto whitespace-nowrap">
        <div :for.with_index={{ {%{child: group}, index} <- @groups }}>
          <Otherwise condition={{ index == @group_index }}>
            <span class="px-2 rounded-full bg-hb-ba dark:bg-hb-ba-dark text-hb-aa dark:text-hb-aa-dark">
              {{ group.name }}
            </span>

            <template slot="otherwise">
              <button :on-click="redirect" phx-value-index={{ index }} type="button" class="px-2 rounded-full hover:bg-hb-ca dark:hover:bg-hb-ca-dark focus:outline-none focus:bg-hb-ca dark:focus:bg-hb-ca-dark">
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
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, %{"group_index" => index, "refetch" => true}))}
  end

  def handle_event("toggle_dark_mode", _value, %{assigns: %{dark_mode: dark_mode}} = socket) do
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, %{"dark_mode" => !dark_mode, "refetch" => true}))}
  end

  def handle_event("toggle_options", _value, %{assigns: %{show_options: show_options}} = socket) do
    {:noreply,
     LiveView.push_patch(socket, to: updated_route(socket, %{"show_options" => !show_options, "refetch" => true}))}
  end

  defp updated_route(%{assigns: %{params: params}} = socket, new_params) do
    Router.Helpers.dashboard_path(socket, :index, Map.merge(params, new_params))
  end
end
