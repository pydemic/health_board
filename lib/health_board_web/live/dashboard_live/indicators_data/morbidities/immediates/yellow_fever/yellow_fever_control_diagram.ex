defmodule HealthBoardWeb.DashboardLive.IndicatorsData.YellowFeverControlDiagram do
  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias HealthBoardWeb.DashboardLive.IndicatorsData.MorbidityControlDiagram

  @indicator MorbidityControlDiagram
  @default_context {:yellow_fever, :residence}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> IndicatorsData.exec_and_put(:modifiers, :context, &@indicator.get_context(&1, @default_context))
    |> @indicator.fetch()
  end
end
