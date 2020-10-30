defmodule HealthBoard.Release.Seeders.Contexts.Geo.Region do
  require Logger
  alias HealthBoard.Contexts.Geo.Region
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "geo/regions.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, Region, &parse/1, opts)
  end

  defp parse([country_id, id, name, abbr, lat, lng]) do
    %{
      country_id: String.to_integer(country_id),
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
