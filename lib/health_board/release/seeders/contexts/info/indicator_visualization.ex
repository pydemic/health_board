defmodule HealthBoard.Release.Seeders.Contexts.Info.IndicatorVisualization do
  require Logger
  alias HealthBoard.Contexts.Info.IndicatorVisualization
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/indicators_visualizations.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, IndicatorVisualization, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([indicator_id, visualization_id, id, name, description], _file_name) do
    %{
      id: id,
      name: name,
      description: description,
      indicator_id: indicator_id,
      visualization_id: visualization_id
    }
  end
end
