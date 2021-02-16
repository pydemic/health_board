defmodule HealthBoardWeb.DashboardLive.Components.ChoroplethMapsCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.ElementsFragments
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <ElementsFragments.Card :let={{ data: data }} element={{ @card }} params={{ @params }}>
      <p :if={{ not is_nil(Map.get(data, :value)) }} class="text-2xl font-bold">
        {{ data.value }}
        <span :if={{ Map.has_key?(@params, :suffix) }} class="text-sm font-normal">
          {{ @params.suffix }}
        </span>
      </p>

      <p :if={{ is_nil(Map.get(data, :value)) }} class="text-2xl font-bold">
        N/A
      </p>
    </ElementsFragments.Card>
    """
  end
end