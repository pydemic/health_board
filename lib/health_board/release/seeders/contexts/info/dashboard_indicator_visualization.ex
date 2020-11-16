defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardIndicatorVisualization do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardIndicatorVisualization
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/dashboards_indicators_visualizations.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, DashboardIndicatorVisualization, &parse/2, opts)
  end

  defp parse([indicator_visualization_id], dashboard_id) do
    %{
      dashboard_id: dashboard_id,
      indicator_visualization_id: indicator_visualization_id
    }
  end
end
