defmodule HealthBoard.Release.Seeders.Contexts.Info.DashboardIndicatorVisualization do
  require Logger
  alias HealthBoard.Contexts.Info.DashboardIndicatorVisualization
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/dashboards_indicators_visualizations.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, DashboardIndicatorVisualization, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([dashboard_id, indicator_visualization_id], _file_name) do
    %{
      dashboard_id: dashboard_id,
      indicator_visualization_id: indicator_visualization_id
    }
  end
end
