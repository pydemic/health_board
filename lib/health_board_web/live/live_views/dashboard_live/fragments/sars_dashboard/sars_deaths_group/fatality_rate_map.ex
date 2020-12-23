defmodule HealthBoardWeb.DashboardLive.Fragments.SarsDashboard.FatalityRateMap do
  use Surface.Component

  alias HealthBoardWeb.LiveComponents.{CardHeaderMenu, CardOffcanvasMenu, DataCard, IndeterminateLoading}
  alias Phoenix.LiveView

  prop card, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataCard id={{ @card.id }} :let={{ data: data }} width_l={{ 2 }} width_m={{ 1 }}>
      <template slot="header" :let={{ data: data }}>
        <CardHeaderMenu card={{ @card }} data={{ data }} show_data={{ false }} show_link={{ false }} show_labels={{ true }} />
      </template>

      <template slot="body" :let={{ data: data }}>
        <div :show={{ Enum.any?(data) }} id={{ @card.id }} class="uk-card-body hb-map" phx-hook="Map"></div>
        <IndeterminateLoading :if={{ Enum.empty?(data) }} />
      </template>

      <CardOffcanvasMenu card={{ @card }} data={{ data }} show_data={{ false }} show_labels={{ true }} />
    </DataCard>
    """
  end

  @spec put_data(String.t(), map) :: any
  def put_data(id, data) do
    send_update(__MODULE__, id: id, data: data)
  end
end
