defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardIndicatorVisualization do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardIndicatorVisualization
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/dashboards_indicators_visualizations.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, DashboardIndicatorVisualization, &parse/1, opts)
  end

  defp parse([dashboard_id, indicator_visualization_id]) do
    %{
      dashboard_id: dashboard_id,
      indicator_visualization_id: indicator_visualization_id
    }
  end
end
