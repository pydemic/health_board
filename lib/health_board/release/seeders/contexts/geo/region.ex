defmodule HealthBoard.Release.Seeders.Contexts.Geo.Region do
  require Logger
  alias HealthBoard.Contexts.Geo.Regions
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "geo/regions.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
  end

  defp parse_and_seed([id, name, abbr, lat, lng, country_id]) do
    attrs = %{
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng),
      country_id: String.to_integer(country_id)
    }

    {:ok, _region} = Regions.create(attrs)
    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
