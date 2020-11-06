defmodule HealthBoard.Release.Seeders.Contexts.Info.IndicatorVisualization do
  require Logger
  alias HealthBoard.Contexts.Info.IndicatorVisualization
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/indicators_visualizations.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, IndicatorVisualization, &parse/1, opts)
  end

  defp parse([indicator_id, visualization_id, id, name, description]) do
    %{
      id: id,
      name: name,
      description: description,
      indicator_id: indicator_id,
      visualization_id: visualization_id
    }
  end
end
