defmodule HealthBoard.Release.Seeders.Contexts.Geo.State do
  require Logger
  alias HealthBoard.Contexts.Geo.State
  alias HealthBoard.Release.Seeders.Seeder

  @path "geo/states.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts = Keyword.put(opts, :skip_headers, true)
    Seeder.seed(@path, State, &parse/2, opts)
  end

  defp parse([country_id, region_id, id, name, abbr, lat, lng], _file_name) do
    %{
      country_id: String.to_integer(country_id),
      region_id: String.to_integer(region_id),
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
