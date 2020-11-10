defmodule HealthBoard.Release.Seeders.Contexts.Geo.Country do
  require Logger
  alias HealthBoard.Contexts.Geo.Country
  alias HealthBoard.Release.Seeders.Seeder

  @path "geo/countries.zip"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts = Keyword.put(opts, :skip_headers, true)
    Seeder.seed(@path, Country, &parse/2, opts)
  end

  defp parse([id, name, abbr, lat, lng], _file_name) do
    %{
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
