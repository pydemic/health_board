defmodule HealthBoardWeb.DashboardLive.IndicatorsData.SpottedFeverIncidence do
  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias HealthBoardWeb.DashboardLive.IndicatorsData.MorbidityIncidence

  @default_context {:spotted_fever, :residence}

  @spec fetch(IndicatorsData.t()) :: IndicatorsData.t()
  def fetch(indicators_data) do
    indicators_data
    |> IndicatorsData.exec_and_put(:modifiers, :context, &MorbidityIncidence.get_context(&1, @default_context))
    |> MorbidityIncidence.fetch()
  end
end
