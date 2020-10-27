defmodule HealthBoard.Release.Seeders.Contexts.Geo.HealthRegion do
  @moduledoc """
  Seed `HealthBoard.Contexts.Geo.HealthRegion` data.
  """

  require Logger
  alias HealthBoard.Contexts.Geo.HealthRegions
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "geo/health_regions.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
    :ok
  end

  defp parse_and_seed([id, name]) do
    state_id =
      id
      |> String.slice(0, 2)
      |> String.to_integer()

    attrs = %{
      id: String.to_integer(id),
      name: name,
      state_id: state_id
    }

    {:ok, _health_region} = HealthRegions.create(attrs)
    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
