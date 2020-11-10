defmodule HealthBoard.Release.Seeders.Contexts.Info.Indicator do
  require Logger
  alias HealthBoard.Contexts.Info.Indicator
  alias HealthBoard.Release.Seeders.Seeder

  @path "info/indicators.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Seeder.seed(@path, Indicator, &parse/2, Keyword.put(opts, :skip_headers, true))
  end

  defp parse([id, name, description, math], _file_name) do
    %{
      id: id,
      name: name,
      description: description,
      math: math
    }
  end
end
