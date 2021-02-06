defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.SourcesModal do
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
        id="{{ @id }}-source"
        title="FONTES">
        <template slot="body">
          <hr class="solid">
          <div :for={{ item <- @data }}>
            <br/> <b> NOME: </b> {{ Humanize.format(item.source.name) }}
            <br/> <b> DESCRIÇÃO: </b> {{ Humanize.format(item.source.description) }}
            <span :if={{ item.source.link != nil }}> <br/> <b> ENDEREÇO DA FONTE: </b> <a href={{ item.source.link }}>Clique aqui</a> </span>
            <br/> <b> FREQUÊNCIA DE ATUALIZAÇÃO DA BASE: </b> {{ Humanize.format(item.source.update_rate) }}
            <br/> <b> DATA DE EXTRAÇÃO: </b> {{ Humanize.format(item.source.extraction_date) }}
            <br/> <b> DATA DA ÚLTIMA ATUALIZAÇÃO: </b> {{ Humanize.format(item.source.last_update_date) }}
            <hr class="solid">
          </div>
        </template>
        <template slot="external_button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
            <path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"/>
            <path fill-rule="evenodd" d="M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a1 1 0 101.414 1.415l1.261-1.261A4 4 0 108 10zm-2 4a2 2 0 114 0 2 2 0 01-4 0z" clip-rule="evenodd"/>
          </svg>
        </template>
        <template slot="icon">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="inline w-5 h-5 text-gray-700">
            <path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2h-1.528A6 6 0 004 9.528V4z"/>
            <path fill-rule="evenodd" d="M8 10a4 4 0 00-3.446 6.032l-1.261 1.26a1 1 0 101.414 1.415l1.261-1.261A4 4 0 108 10zm-2 4a2 2 0 114 0 2 2 0 01-4 0z" clip-rule="evenodd"/>
          </svg>
        </template>
      </Modal>
    </span>
    """
  end
end
