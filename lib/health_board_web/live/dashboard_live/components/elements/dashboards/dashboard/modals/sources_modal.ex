defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Modals.SourcesModal do
  use Surface.LiveComponent
  alias HealthBoardWeb.DashboardLive.Components.Dashboard.Modals
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop sources, :list, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 z-20 bg-black bg-opacity-75">
      <div class="mt-10 h-5/6 w-11/12 flex items-center mx-auto">
        <div class="flex flex-col bg-white p-5 mx-auto rounded-lg shadow-xl max-h-full">
          <div class="sm:flex sm:items-start max-h-full">
            <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10">
              <Icons.Source />
            </div>

            <div class="mt-3 text-center sm:mt-2 sm:ml-4 sm:text-left max-h-full">
              <h3 class="text-lg leading-6 font-medium">{{ @name }}: Fontes</h3>
            </div>
          </div>

          <div class="mt-3 px-5 flex-shrink overflow-y-auto">
            <div :for={{ %{source: source} <- @sources }} class="border border-gray-300 rounded-lg my-5">
              <div class="p-5">
                <h3 class="text-lg leading-6 font-medium text-gray-900">{{ source.name }}</h3>
                <p :if={{ source.description }} class="mt-2 max-w-2xl text-xs text-gray-500">{{ source.description }}</p>
              </div>

              <div class="border-t border-gray-300">
                <dl>
                  <div :if={{ source.update_rate }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Frequência de atualização da base</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ source.update_rate }}</dd>
                  </div>

                  <div :if={{ source.last_update_date }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Data da última atualização da base</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ Humanize.date source.last_update_date }}</dd>
                  </div>

                  <div :if={{ source.extraction_date }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Data da extração</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">{{ Humanize.date source.extraction_date }}</dd>
                  </div>

                  <div :if={{ source.link }} class="bg-gray-50 p-5 sm:grid sm:grid-cols-3 sm:gap-4 rounded-lg">
                    <dt class="text-sm font-medium text-gray-500">Link</dt>
                    <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2 text-center">
                      <a href={{ source.link }} target="_blank" class="mr-2"><Icons.Link /></a>
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
    Modals.hide_sources()

    {:noreply, socket}
  end
end
