defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.DynamicFilter
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.Filter
  alias HealthBoardWeb.Router
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop filters, :list, required: true
  prop params, :map, required: true

  data changes, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 z-20 bg-black bg-opacity-75">
      <div class="mt-10 h-5/6 w-11/12 flex items-center mx-auto">
        <div class="flex flex-col p-5 mx-auto max-h-full w-full rounded-lg bg-hb-a dark:bg-hb-a-dark">
          <div class="sm:flex sm:items-start max-h-full">
            <div class="flex items-center justify-center flex-shrink-0 sm:mx-0 mx-auto sm:h-10 h-12 sm:w-10 w-12 rounded-full bg-hb-aa dark:bg-hb-aa-dark text-hb-ba dark:text-hb-ba-dark">
              <Filter />
            </div>

            <div class="sm:mt-2 mt-3 sm:ml-4 sm:text-left text-center max-h-full">
              <h3 class="text-lg leading-6 font-medium">{{ @name }}: Filtros</h3>
            </div>
          </div>

          <div class="px-5 mt-3 flex-shrink overflow-y-auto w-full">
            <div :for={{ filter <- @filters }} class="my-5 border rounded-lg border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
              <div class="p-5">
                <h3 class="text-lg leading-6 font-medium text-hb-aa">{{ filter.name }}</h3>
                <p class="mt-2 max-w-2xl text-xs">{{ filter.description }}</p>
              </div>

              <div class="p-5 border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
                <dl>
                  <div class="sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-semibold">Valor atual</dt>
                    <dd class="sm:col-span-2 sm:mt-0 mt-1 text-sm">{{ filter.verbose_value }}</dd>
                  </div>

                </dl>
              </div>

              <div class="p-5 border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
                <DynamicFilter id={{ filter.sid }} changes={{ @changes }} filter={{ filter }} />
              </div>
            </div>
          </div>

          <div class="border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
            <div class="sm:flex sm:px-0 px-4 py-3">
              <span class="flex mt-5 sm:w-auto w-full rounded-md">
                <button type="button" :on-click="save" class="px-4 py-2 inline-flex justify-center w-full text-sm rounded-md border border-green-500 dark:border-green-600 text-green-500 dark:text-green-600 border-text-green-500 dark:border-text-green-600 hover:text-hb-a dark:hover:text-hb-a-dark hover:bg-green-500 dark:hover:bg-green-600 focus:outline-none focus:text-hb-a dark:focus:text-hb-a-dark focus:bg-green-500 dark:focus:bg-green-600">
                  Salvar
                </button>
              </span>

              <span class="sm:flex-grow"></span>

              <span class="flex mt-5 sm:w-auto w-full rounded-md">
                <button type="button" :on-click="hide" class="px-4 py-2 inline-flex justify-center w-full text-sm text-opacity-50 rounded-md border border-opacity-50 text-hb-b dark:text-hb-b-dark border-hb-b dark:border-hb-b-dark hover:text-hb-ca dark:hover:text-hb-aa hover:border-hb-ca dark:hover:border-hb-aa focus:outline-none focus:text-hb-ca dark:focus:text-hb-aa focus:border-hb-ca dark:focus:border-hb-aa dark:hover:text-opacity-100 dark:hover:border-opacity-100 dark:focus:text-opacity-100 dark:focus:border-opacity-100">
                  Fechar
                </button>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @spec handle_event(String.t(), map, LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("hide", _value, socket) do
    Modals.hide_filters()

    {:noreply, socket}
  end

  def handle_event("save", _value, socket) do
    Modals.hide_filters()

    socket =
      if Enum.any?(socket.assigns.changes) do
        LiveView.push_patch(socket, to: updated_route(socket))
      else
        socket
      end

    {:noreply, socket}
  end

  defp updated_route(%{assigns: %{params: params, changes: changes}} = socket) do
    Router.Helpers.dashboard_path(socket, :index, Map.put(Map.merge(params, changes), "refetch", true))
  end

  @spec update_changes(pid, map) :: any
  def update_changes(pid \\ self(), changes) do
    send_update(pid, __MODULE__, id: :filters_modal, changes: changes)
  end
end
