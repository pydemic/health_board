defmodule HealthBoard.Release.Seeders.Contexts.Info.Filter do
  require Logger
  alias HealthBoard.Contexts.Info.Filter
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/filters.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, Filter, &parse/1, opts)
  end

  defp parse([id, name]) do
    %{
      id: id,
      name: name
    }
  end
end
