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
        title="INDICADORES">
        <template slot="body">
          <hr class="solid">
          <div :for={{ item <- @data }}>
            <br/> <b> DESCRIÇÃO: </b> {{ Humanize.format(item.indicator.description) }}
            <span :if={{ item.indicator.link != nil }}> <br/> <b> ENDEREÇO DA FONTE: </b> <a href={{ item.indicator.link }}>Clique aqui</a> </span>
            <br/> <b> FÓRMULA: </b> {{ Humanize.format(item.indicator.formula) }}
            <br/> <b> UNIDADE DE MEDIDA: </b> {{ Humanize.format(item.indicator.measurement_unit) }}
            <hr class="solid">
          </div>
        </template>
        <template slot="external_button">
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
