defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.IndicatorsModal do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Modal
  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop data, :list, required: true
  prop id, :string, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <span :if={{ Enum.any?(@data) }}>
      <Modal
        id="{{ @id }}-indicator"
        title="Indicadores">
        <template slot="body">
          <hr class="solid my-4">
          <div :for={{ item <- @data }}>
            <b> Descrição: </b> {{ Humanize.format(item.indicator.description) }}
            <span :if={{ item.indicator.link != nil }}> <br/> <b> Endereço da fonte: </b> <a href={{ item.indicator.link }}>Clique aqui</a> </span>
            <br/> <b> Fórmula: </b> {{ Humanize.format(item.indicator.formula) }}
            <br/> <b> Unidade de medida: </b> {{ Humanize.format(item.indicator.measurement_unit) }}
            <hr class="solid my-4">
          </div>
        </template>
        <template slot="open_button">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="inline w-5 h-5 text-gray-700">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </template>
        <template slot="icon">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="inline w-5 h-5 text-gray-700">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </template>
      </Modal>
    </span>
    """
  end
end
