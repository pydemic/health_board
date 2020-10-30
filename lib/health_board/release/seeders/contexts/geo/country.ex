defmodule HealthBoard.Release.Seeders.Contexts.Geo.Country do
  require Logger
  alias HealthBoard.Contexts.Geo.Country
  alias HealthBoard.Release.Seeders.InsertAllCSVSeeder

  @path "geo/countries.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    InsertAllCSVSeeder.seed(@path, Country, &parse/1, opts)
  end

  defp parse([id, name, abbr, lat, lng]) do
    %{
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }
  end
end
