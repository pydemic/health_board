defmodule HealthBoard.Release.Seeders.Contexts.Demographic.HealthRegionPopulation do
  require Logger
  alias HealthBoard.Contexts.Demographic.HealthRegionPopulation
  alias HealthBoard.Release.Seeders.Seeder

  @batch_size 3_000
  @path "demographic/population/health_regions_population.zip"

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

  @spec seed(keyword()) :: :ok
  def seed(opts \\ []) do
    opts =
      opts
      |> Keyword.put(:batch_size, @batch_size)
      |> Keyword.put(:skip_headers, true)

    Seeder.seed(@path, HealthRegionPopulation, &parse/2, opts)
  end

  defp parse(data, _file_name) do
    @fields
    |> Enum.zip(Enum.map(data, &String.to_integer/1))
    |> Map.new()
  end
end
