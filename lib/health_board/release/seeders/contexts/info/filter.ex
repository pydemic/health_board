defmodule HealthBoard.Release.Seeders.Contexts.Info.Filter do
  require Logger
  alias HealthBoard.Contexts.Info.Filter
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/filters.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, Filter, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([id, name], _file_name) do
    %{
      id: id,
      name: name
    }
  end
end
