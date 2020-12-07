defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HeatTable do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{Card, CardHeaderMenu, CardOffcanvasMenu}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card_id, :atom, required: true
  prop card, :map, required: true

  @labels %{}

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    card = put_in(assigns.card, [:data, :labels], @labels)
    data = card.data
    headers = data[:headers]

    ~H"""
    <Card :if={{ Enum.any?(@card.data) }} width_l={{ 1 }} width_m={{ 1 }} >
      <template slot="header">
        <CardHeaderMenu card_id={{ @card_id }} card={{ card }} show_data={{ false }} />
      </template>

      <template slot="body">
        <div class="uk-card-body uk-overflow-auto">
          <table class="uk-table uk-table-small uk-table-middle uk-text-small hb-table">
            <thead>
              <tr>
                <th class="hb-table-empty"></th>
                <th :for={{ header <- headers }} class="hb-table-header uk-text-emphasis" style="height: 155px;">
                  <div><span>{{ if String.length(header) > 43, do: String.slice(header, 0, 40) <> "...", else: header }}</span></div>
                </th>
              </tr>
            </thead>

            <tbody>
              <tr :for={{ line <- data.lines }} class="hb-table-row">
                <td class={{ "uk-text-right", "uk-text-emphasis", "uk-text-nowrap" }}>
                  {{ line.name }}
                </td>

                <td
                  :for={{ {cell, header} <- Enum.zip(line.cells, headers) }}
                  class={{ "hb-table-item", "uk-text-center", "uk-text-secondary", "hb-table-choropleth-#{cell.group}" }}
                  uk-tooltip={{ "Casos de #{header} em #{line.name} - #{cell.cases}" }}>
                  {{ if not is_nil(cell.value), do: Humanize.number(cell.value), else: "" }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <CardOffcanvasMenu card_id={{ @card_id }} card={{ card }} />
    </Card>
    """
  end
end
