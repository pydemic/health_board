defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.SituationReport do
  @spec icu_rate_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def icu_rate_table(_data, _params) do
    :ok
  end

  @spec summary_table(map, map) :: {:ok, {:emit, map}} | :ok | {:error, any}
  def summary_table(_data, _params) do
    :ok
  end
end
