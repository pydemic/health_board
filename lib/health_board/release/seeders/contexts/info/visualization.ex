defmodule HealthBoard.Release.Seeders.Contexts.Info.Visualization do
  require Logger
  alias HealthBoard.Contexts.Info.Visualization
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/visualizations.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, Visualization, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([id, name, description], _file_name) do
    %{
      id: id,
      name: name,
      description: description
    }
  end
end
