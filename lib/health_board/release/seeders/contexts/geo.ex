defmodule HealthBoard.Release.Seeders.Contexts.Geo do
  alias HealthBoard.Release.Seeders.Contexts.Geo

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Geo.Country.seed(opts)
    Geo.Region.seed(opts)
    Geo.State.seed(opts)
    Geo.HealthRegion.seed(opts)
    Geo.City.seed(opts)
  end
end
