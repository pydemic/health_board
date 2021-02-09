defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.FiltersModal do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Modal
  alias Phoenix.LiveView

  prop data, :list, required: true
  prop id, :string, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <span :if={{ Enum.any?(@data) }}>
      <Modal
        id="{{ @id }}-filters"
        title="FILTROS">
        <template slot="body">
          <hr class="solid">
            Filtros
          <hr class="solid">
        </template>
        <template slot="open_button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
            <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd"/>
          </svg>
        </template>
        <template slot="icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
            <path fill-rule="evenodd" d="M3 3a1 1 0 011-1h12a1 1 0 011 1v3a1 1 0 01-.293.707L12 11.414V15a1 1 0 01-.293.707l-2 2A1 1 0 018 17v-5.586L3.293 6.707A1 1 0 013 6V3z" clip-rule="evenodd"/>
          </svg>
        </template>
      </Modal>
    </span>
    """
  end
end
