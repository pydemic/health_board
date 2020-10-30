defmodule HealthBoard.Release.Seeders.Contexts.Geo.HealthRegion do
  require Logger
  alias HealthBoard.Contexts.Geo.HealthRegion
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "geo/health_regions.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, HealthRegion, &parse/1, opts)
  end

  defp parse([country_id, region_id, state_id, id, name, lat, lng]) do
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
