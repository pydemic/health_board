defmodule HealthBoard.Release.Seeders.Contexts.Geo.Country do
  require Logger
  alias HealthBoard.Contexts.Geo.Countries
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "geo/countries.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
  end

  defp parse_and_seed([id, name, abbr, lat, lng]) do
    attrs = %{
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng)
    }

    {:ok, _country} = Countries.create(attrs)
    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
