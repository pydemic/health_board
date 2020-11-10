defmodule HealthBoard.Release.Seeders.Contexts.Info do
  alias HealthBoard.Release.Seeders.Contexts.Info

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Info.Dashboard.seed(opts)
    Info.Filter.seed(opts)
    Info.Indicator.seed(opts)
    Info.Visualization.seed(opts)

    Info.DashboardFilter.seed(opts)
    Info.IndicatorChild.seed(opts)
    Info.IndicatorVisualization.seed(opts)

    Info.DashboardIndicatorVisualization.seed(opts)
  end
end
