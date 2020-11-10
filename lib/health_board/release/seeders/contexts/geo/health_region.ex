defmodule HealthBoard.Release.Seeders.Contexts.Geo.HealthRegion do
  require Logger
  alias HealthBoard.Contexts.Geo.HealthRegion
  alias HealthBoard.Release.Seeders.Seeder

  @path "geo/health_regions.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts = Keyword.put(opts, :skip_headers, true)
    Seeder.seed(@path, HealthRegion, &parse/2, opts)
  end

  defp parse([country_id, region_id, state_id, id, name, lat, lng], _file_name) do
    %{
      country_id: String.to_integer(country_id),
      region_id: String.to_integer(region_id),
      state_id: String.to_integer(state_id),
      id: String.to_integer(id),
      name: name,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
