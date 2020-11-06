defmodule HealthBoard.Release.Seeders.Contexts.Info.Visualization do
  require Logger
  alias HealthBoard.Contexts.Info.Visualization
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/visualizations.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, Visualization, &parse/1, opts)
  end

  defp parse([id, name, description]) do
    %{
      id: id,
      name: name,
      description: description
    }
  end
end
