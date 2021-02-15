defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.FiltersModal.DynamicFilter
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
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
        <div class="flex flex-col bg-white p-5 mx-auto rounded-lg shadow-xl max-h-full w-full">
          <div class="sm:flex sm:items-start max-h-full">
            <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10">
              <Icons.Filter />
            </div>

            <div class="mt-3 text-center sm:mt-2 sm:ml-4 sm:text-left max-h-full">
              <h3 class="text-lg leading-6 font-medium">{{ @name }}: Filtros</h3>
            </div>
          </div>

          <div class="mt-3 px-5 flex-shrink overflow-y-auto w-full">
            <div :for={{ filter <- @filters }} class="border border-gray-300 rounded-lg my-5">
              <div class="p-5">
                <h3 class="text-lg leading-6 font-medium text-gray-900">{{ filter.name }}</h3>
                <p class="mt-2 max-w-2xl text-xs text-gray-500">{{ filter.description }}</p>
              </div>

              <div class="border-t border-gray-300">
                <dl>
                  <div class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Valor atual</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ filter.verbose_value }}</dd>
                  </div>

                  <DynamicFilter id={{ filter.sid }} changes={{ @changes }} filter={{ filter }} />
                </dl>
              </div>
            </div>
          </div>

          <div class="bg-white">
            <hr />

            <div class="px-4 py-3 sm:px-0 sm:flex">
              <span class="mt-5 flex w-full rounded-md shadow-sm sm:w-auto">
                <button type="button" :on-click="save" class="inline-flex justify-center w-full rounded-md border border-green-400 px-4 py-2 bg-green-300 text-base leading-6 font-medium text-gray-700 shadow-sm focus:outline-none hover:text-black sm:text-sm sm:leading-5">
                  Salvar
                </button>
              </span>

              <span class="sm:flex-grow"></span>

              <span class="mt-5 flex w-full rounded-md shadow-sm sm:w-auto">
                <button type="button" :on-click="hide" class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-indigo-700 focus:text-indigo-700 sm:text-sm sm:leading-5">
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
