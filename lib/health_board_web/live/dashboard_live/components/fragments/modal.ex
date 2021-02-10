defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Modal do
  use Surface.Component

  slot body, required: true
  slot open_button, required: true
  slot icon, required: false

  prop id, :string
  prop title, :string

  def render(assigns) do
    ~H"""
    <div class="ml-3 relative"
        x-data=" { open: false }">
      <div>
        <button
          class="max-w-xs flex items-center text-sm rounded-full
            text-white focus:outline-none focus:shadow-solid"
          id="modal-{{ @id }}"
          aria-label={{  @title }}
          aria-haspopup="true"
          @click="open = !open">
          <slot name="open_button"/>
        </button>
      </div>
      <div id={{ @id }}
        x-show="open"
        x-cloak
        class="fixed inset-0 w-full h-full z-20 bg-black bg-opacity-75 duration-300 overflow-y-auto">
        <div class="relative sm:w-3/4 md:w-1/2 lg:w-1/3 mx-2 sm:mx-auto mt-10 mb-24 opacity-100">
          <div x-show="open"
              x-cloak
              x-transition:enter="ease-out duration-300"
              x-transition:enter-start="opacity-0"
              x-transition:enter-end="opacity-100"
              x-transition:leave="ease-in duration-300"
              x-transition:leave-start="opacity-100"
              x-transition:leave-end="opacity-0"
              class="fixed inset-0 transition-opacity">
          </div>
          <div x-show="open"
              x-cloak
              @click.away="open = false"
              x-transition:enter="ease-out duration-300"
              x-transition:enter-start="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              x-transition:enter-end="opacity-100 translate-y-0 sm:scale-100"
              x-transition:leave="ease-in duration-300"
              x-transition:leave-start="opacity-100 translate-y-0 sm:scale-100"
              x-transition:leave-end="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
              class="bg-white rounded-lg overflow-hidden shadow-xl transform transition-all sm:max-w-lg sm:w-full"
              role="dialog"
              aria-modal="true"
              aria-labelledby="modal-headline"
              aria-describedby="modal-description">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10">
                  <slot name="icon"/>
                </div>
                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 class="text-lg leading-6 font-medium"
                    id="modal-headline">
                      {{ @title }}
                  </h3>
                  <div class="mt-2">
                    <slot name="body"/>
                  </div>
                </div>
              </div>
            </div>
            <div class="px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
              <span class="mt-3 flex w-full rounded-md shadow-sm sm:mt-0 sm:w-auto">
                <button type="button"
                        class="inline-flex justify-center w-full rounded-md border border-gray-300 px-4 py-2 bg-white text-base leading-6 font-medium text-gray-700 shadow-sm hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue transition ease-in-out duration-150 sm:text-sm sm:leading-5"
                        @click="open = false">
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
end
