defmodule HealthBoard.Release.Seeders.Contexts.Info.IndicatorChild do
  require Logger
  alias HealthBoard.Contexts.Info.IndicatorChild
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "info/indicators_children.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, IndicatorChild, &parse/1, opts)
  end

  defp parse([indicator_id, child_id]) do
    %{
      indicator_id: indicator_id,
      child_id: child_id
    }
  end
end
