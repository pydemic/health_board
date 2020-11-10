defmodule HealthBoard.Release.Seeders.Contexts.Geo.City do
  require Logger
  alias HealthBoard.Contexts.Geo.City
  alias HealthBoard.Release.Seeders.Seeder

  @batch_size 4_000
  @path "geo/cities.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts =
      opts
      |> Keyword.put(:batch_size, @batch_size)
      |> Keyword.put(:skip_headers, true)

    Seeder.seed(@path, City, &parse/2, opts)
  end

  defp parse([country_id, region_id, state_id, health_region_id, id, name, lat, lng], _file_name) do
    %{
      country_id: String.to_integer(country_id),
      region_id: String.to_integer(region_id),
      state_id: String.to_integer(state_id),
      health_region_id: String.to_integer(health_region_id),
      id: String.to_integer(id),
      name: name,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
