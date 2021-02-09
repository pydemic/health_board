defmodule HealthBoardWeb.DashboardLive.Components.Fragments.OffCanvas do
  use Surface.Component

  slot body, required: true
  slot open_button, required: true

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
          id="dashboard-menu-{{ @id }}"
          @click="open = !open">
          <slot name="open_button"/>
        </button>
      </div>
      <div id={{ @id }}
        x-show="open"
        x-cloak>
        <div class="z-50 fixed bottom-0 inset-x-0 px-4 pb-4 sm:inset-0 sm:flex sm:items-center sm:justify-center">
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
          <div class="absolute inset-0 bg-gray-500 opacity-75"></div>
          <div
            x-show.transition.opacity.duration.500="open"
            @click="open = false"
            class="fixed inset-0 bg-black bg-opacity-25"></div>
          <div
            class="fixed transition duration-300 right-0 top-0 transform w-full max-w-xs h-screen bg-gray-100 overflow-hidden"
            :class="{'translate-x-full': !open}">
            <button
              @click="open = false"
              x-ref="closeButton"
              :class="{'focus:outline-none': !usedKeyboard}"
              class="fixed top-0 right-0 mr-4 mt-2 z-50">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
            <div class="p-16 px-6 absolute top-0 h-full overflow-y-scroll">
              <div class="py-5 text-2xl font-bold">
                <h2>
                  {{ @title }}
                </h2>
              </div>
              <slot name="body"/>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
