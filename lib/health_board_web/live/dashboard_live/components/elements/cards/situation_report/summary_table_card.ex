defmodule HealthBoardWeb.DashboardLive.Components.SituationReport.SummaryTableCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Card
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card :let={{ data: data }} element={{ @card }} params={{ @params }}>
      <p :if={{ is_nil(Map.get(data, :value)) }} class="text-2xl font-bold">
        N/A
      </p>
    </Card>
    """
  end
end
