defmodule HealthBoard.Release.Seeders.Contexts.Info.Indicator do
  require Logger
  alias HealthBoard.Contexts.Info.Indicator
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/indicators.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, Indicator, &parse/1, opts)
  end

  defp parse([id, name, description, math]) do
    %{
      id: id,
      name: name,
      description: description,
      math: math
    }
  end
end
