defmodule HealthBoard.Release.Seeders.Contexts.Geo.City do
  require Logger
  alias HealthBoard.Contexts.Geo.Cities
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "geo/cities.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
  end

  defp parse_and_seed([id, name, lat, lng, _state_id, health_region_id]) do
    attrs = %{
      id: String.to_integer(id),
      name: name,
      lat: String.to_float(lat),
      lng: String.to_float(lng),
      health_region_id: String.to_integer(health_region_id)
    }

    {:ok, _city} = Cities.create(attrs)
    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
