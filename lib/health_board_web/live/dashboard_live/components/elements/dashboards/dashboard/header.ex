defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Header do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Fragments.{Cooldown, Otherwise}
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.{Home, Eye, EyeOff, Moon, Refresh, Sun}
  alias HealthBoardWeb.DashboardLive.ParamsManager
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop dashboard, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <header class="lg:px-10 sm:px-6 px-4 w-full divide-y divide-hb-ba dark:divide-hb-ba-dark bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
      <div class="flex justify-between items-center">
        <div class="py-5 text-2xl font-bold">
          <h2>{{ @dashboard.name }}</h2>
        </div>

        <div class="flex-grow">
        </div>

        <a href={{ cleared_route(@socket, @dashboard) }} title="Restaurar parâmetros aos valores padrões" class="py-5 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
          <Home />
        </a>

        <Cooldown id={{ "refresh_dashboard_#{@id}" }} message="Aguarde antes de atualizar novamente as informações do painel" wrapper_class="py-5 ml-2">
          <button :on-click="refresh_dashboard" title="Atualizar informações do painel" class="py-5 ml-2 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
            <Refresh />
          </button>
        </Cooldown>

        <button :on-click="toggle_options" class="py-5 ml-2 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
          <Otherwise condition={{ @dashboard.show_options }} true_title="Ocultar opções adicionais" false_title="Mostrar opções adicionais">
            <EyeOff />

            <template slot="otherwise">
              <Eye />
            </template>
          </Otherwise>
        </button>

        <button :on-click="toggle_dark_mode" class="py-5 ml-2 hover:text-hb-c-dark dark:hover:text-hb-c focus:outline-none focus:text-hb-c-dark dark:focus:text-hb-c">
          <Otherwise condition={{ @dashboard.dark_mode }} true_title="Desativar modo noturno" false_title="Ativar modo noturno">
            <Sun />

            <template slot="otherwise">
              <Moon />
            </template>
          </Otherwise>
        </button>
      </div>

      <div class="flex justify-between items-center py-5 w-full overflow-x-auto whitespace-nowrap">
        <div :for.with_index={{ {%{child: group}, index} <- @dashboard.children }}>
          <Otherwise condition={{ index == @dashboard.group_index }}>
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
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, %{"group_index" => index}))}
  end

  def handle_event("refresh_dashboard", _value, %{assigns: %{id: id, dashboard: %{params: params}}} = socket) do
    ParamsManager.emit_group_data(socket, params, apply: true)
    Cooldown.trigger("refresh_dashboard_#{id}")
    {:noreply, socket}
  end

  def handle_event("toggle_dark_mode", _value, %{assigns: %{dashboard: %{dark_mode: dark_mode}}} = socket) do
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, %{"dark_mode" => !dark_mode}))}
  end

  def handle_event("toggle_options", _value, %{assigns: %{dashboard: %{show_options: show_options}}} = socket) do
    {:noreply, LiveView.push_patch(socket, to: updated_route(socket, %{"show_options" => !show_options}))}
  end

  defp cleared_route(socket, %{params: params}) do
    Router.Helpers.dashboard_path(socket, :index, Map.take(params, ["id", "dark_mode", "group_index"]))
  end

  defp updated_route(%{assigns: %{dashboard: %{params: params}}} = socket, new_params) do
    Router.Helpers.dashboard_path(socket, :index, Map.merge(params, new_params))
  end
end
