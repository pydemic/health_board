defmodule HealthBoard.Release.Seeders.Contexts.Demographic do
  alias HealthBoard.Release.Seeders.Contexts.Demographic

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    Demographic.CountryPopulation.seed(opts)
    Demographic.RegionPopulation.seed(opts)
    Demographic.StatePopulation.seed(opts)
    Demographic.HealthRegionPopulation.seed(opts)
    Demographic.CityPopulation.seed(opts)

    Demographic.CountryResidentYearlyBirths.seed(opts)
    Demographic.RegionResidentYearlyBirths.seed(opts)
    Demographic.StateResidentYearlyBirths.seed(opts)
    Demographic.HealthRegionResidentYearlyBirths.seed(opts)
    Demographic.CityResidentYearlyBirths.seed(opts)

    Demographic.CountrySourceYearlyBirths.seed(opts)
    Demographic.RegionSourceYearlyBirths.seed(opts)
    Demographic.StateSourceYearlyBirths.seed(opts)
    Demographic.HealthRegionSourceYearlyBirths.seed(opts)
    Demographic.CitySourceYearlyBirths.seed(opts)
    Demographic.HealthInstitutionSourceYearlyBirths.seed(opts)

    Demographic.CountryResidentBirths.seed(opts)
    Demographic.RegionResidentBirths.seed(opts)
    Demographic.StateResidentBirths.seed(opts)
    Demographic.HealthRegionResidentBirths.seed(opts)
    Demographic.CityResidentBirths.seed(opts)

    Demographic.CountrySourceBirths.seed(opts)
    Demographic.RegionSourceBirths.seed(opts)
    Demographic.StateSourceBirths.seed(opts)
    Demographic.HealthRegionSourceBirths.seed(opts)
    Demographic.CitySourceBirths.seed(opts)
    Demographic.HealthInstitutionSourceBirths.seed(opts)
  end
end
