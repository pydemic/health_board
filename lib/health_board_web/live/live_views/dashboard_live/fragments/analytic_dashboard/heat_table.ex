defmodule HealthBoardWeb.DashboardLive.Fragments.AnalyticDashboard.HeatTable do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{CardHeaderMenu, CardOffcanvasMenu, DataCard, IndeterminateLoading}
  alias Phoenix.LiveView

  alias HealthBoardWeb.Helpers.Humanize

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataCard id={{ @card.id }} :let={{ data: data }} width_l={{ 1 }} width_m={{ 1 }} >
      <template slot="header" :let={{ data: data }}>
        <CardHeaderMenu  card={{ @card }} data={{ data }} show_data={{ false }} show_labels={{ true }} show_link={{ false }} />
      </template>

      <template slot="body" :let={{ data: data }}>
        <div class="uk-card-body uk-overflow-auto">
          <table :if={{ Enum.any?(data) }} class="uk-table uk-table-small uk-table-middle uk-text-small hb-table">
            <thead>
              <tr>
                <th class="hb-table-empty"></th>
                <th :for={{ header <- data.table.headers }} class="hb-table-header uk-text-emphasis" style="height: 155px;">
                  <div><span>{{ if String.length(header) > 43, do: String.slice(header, 0, 40) <> "...", else: header }}</span></div>
                </th>
              </tr>
            </thead>

            <tbody>
              <tr :for={{ line <- data.table.lines }} class="hb-table-row">
                <td class={{ "uk-text-right", "uk-text-emphasis", "uk-text-nowrap" }}>
                  {{ line.name }}
                </td>

                <td
                  :for={{ {cell, header} <- Enum.zip(line.cells, data.table.headers) }}
                  class={{ "hb-table-item", "uk-text-center", "uk-text-secondary", "hb-choropleth-#{cell.group}" }}
                  uk-tooltip={{ "Casos de #{header} em #{line.name} - #{cell.cases}" }}>
                  {{ if not is_nil(cell.value), do: Humanize.number(cell.value), else: "" }}
                </td>
              </tr>
            </tbody>
          </table>

          <IndeterminateLoading :if={{ Enum.empty?(data) }} />
        </div>
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} show_data={{ false }} show_labels={{ true }} suffix="%" />
    </DataCard>
    """
  end
end
