defmodule HealthBoard.Release.Seeders.Contexts.Geo.State do
  require Logger
  alias HealthBoard.Contexts.Geo.States
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "geo/states.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
  end

  defp parse_and_seed([id, name, abbr, lat, lng, region_id]) do
    attrs = %{
      id: String.to_integer(id),
      name: name,
      abbr: abbr,
      lat: String.to_float(lat),
      lng: String.to_float(lng),
      region_id: String.to_integer(region_id)
    }

    {:ok, _state} = States.create(attrs)
    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
