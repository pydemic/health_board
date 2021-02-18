defmodule HealthBoardWeb.DashboardLive.Components.ScalarCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Card
  alias HealthBoardWeb.DashboardLive.Components.Fragments.NA
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :let={{ data: data }} element={{ @card }} params={{ @params }}>
      <p :if={{ not is_nil(Map.get(data, :value)) }}>
        <span class="text-2xl font-bold text-hb-aa">
          {{ data.value }}
        </span>

        <span :if={{ Map.has_key?(@params, :suffix) }} class="text-sm">
          {{ @params.suffix }}
        </span>
      </p>

      <NA :if={{ is_nil(Map.get(data, :value)) }} />
    </Card>
    """
  end
end
