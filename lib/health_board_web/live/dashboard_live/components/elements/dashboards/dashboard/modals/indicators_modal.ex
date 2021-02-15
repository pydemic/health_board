defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.IndicatorsModal do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop indicators, :list, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 z-20 bg-black bg-opacity-75">
      <div class="mt-10 h-5/6 w-11/12 flex items-center mx-auto">
        <div class="flex flex-col bg-white p-5 mx-auto rounded-lg shadow-xl max-h-full">
          <div class="sm:flex sm:items-start max-h-full">
            <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10">
              <Icons.Info />
            </div>

            <div class="mt-3 text-center sm:mt-2 sm:ml-4 sm:text-left max-h-full">
              <h3 class="text-lg leading-6 font-medium">{{ @name }}: Indicadores</h3>
            </div>
          </div>

          <div class="mt-3 px-5 flex-shrink overflow-y-auto">
            <div :for={{ %{indicator: indicator} <- @indicators }} class="border border-gray-300 rounded-lg my-5">
              <div class="p-5">
                <h3 class="text-lg leading-6 font-medium text-gray-900">{{ indicator.name }}</h3>

                <p class="mt-2 max-w-2xl text-xs text-gray-500">{{ indicator.description }}</p>
              </div>

              <div class="border-t border-gray-300">
                <dl>
                  <div class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Fórmula</dt>

                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ indicator.formula }}</dd>
                  </div>

                  <div :if={{ indicator.measurement_unit }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Unidade de medida</dt>

                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ indicator.measurement_unit }}</dd>
                  </div>

                  <div :if={{ indicator.link }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Referência</dt>

                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 text-center">
                      <a href={{ indicator.link }} target="_blank" class="mr-2"><Icons.Link /></a>
                    </dd>
                  </div>
                </dl>
              </div>
            </div>
          </div>

          <div class="bg-white">
            <hr />

            <div class="px-4 py-3 sm:px-0 sm:flex sm:flex-row-reverse">
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
    Modals.hide_indicators()

    {:noreply, socket}
  end
end
