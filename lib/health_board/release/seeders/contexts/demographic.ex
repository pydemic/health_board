defmodule HealthBoard.Release.Seeders.Contexts.Demographic do
  alias HealthBoard.Release.Seeders.Contexts.Demographic

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Demographic.CountryPopulation.seed(opts)
    Demographic.RegionPopulation.seed(opts)
    Demographic.StatePopulation.seed(opts)
    Demographic.HealthRegionPopulation.seed(opts)
    Demographic.CityPopulation.seed(opts)
  end
end
