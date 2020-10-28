defmodule HealthBoard.Release.Seeders.Contexts.Demographic.HealthRegionPopulation do
  require Logger
  alias HealthBoard.Contexts.Demographic.HealthRegionsPopulation
  alias HealthBoard.Release.Seeders.CSVSeeder

  @path "demographic/health_regions_population.csv"

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    CSVSeeder.seed(@path, &parse_and_seed/1, opts)
  end

  @fields [
    :health_region_id,
    :year,
    :male,
    :female,
    :age_0_4,
    :age_5_9,
    :age_10_14,
    :age_15_19,
    :age_20_24,
    :age_25_29,
    :age_30_34,
    :age_35_39,
    :age_40_44,
    :age_45_49,
    :age_50_54,
    :age_55_59,
    :age_60_64,
    :age_64_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  defp parse_and_seed(data) do
    data = Enum.map(data, &String.to_integer/1)

    {:ok, _health_region_population} =
      @fields
      |> Enum.zip(data)
      |> Map.new()
      |> HealthRegionsPopulation.create()

    :ok
  rescue
    error -> Logger.error(Exception.message(error))
  end
end
