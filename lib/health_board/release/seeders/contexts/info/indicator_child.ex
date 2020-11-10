defmodule HealthBoard.Release.Seeders.Contexts.Info.IndicatorChild do
  require Logger
  alias HealthBoard.Contexts.Info.IndicatorChild
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/indicators_children.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, IndicatorChild, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([indicator_id, child_id], _file_name) do
    %{
      indicator_id: indicator_id,
      child_id: child_id
    }
  end
end
