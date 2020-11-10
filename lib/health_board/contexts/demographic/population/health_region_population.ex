defmodule HealthBoard.Contexts.Demographic.HealthRegionPopulation do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Demographic.HealthRegionPopulation
  alias HealthBoard.Contexts.Geo

  schema "health_regions_population" do
    field :year, :integer

    field :male, :integer
    field :female, :integer

    field :age_0_4, :integer
    field :age_5_9, :integer
    field :age_10_14, :integer
    field :age_15_19, :integer
    field :age_20_24, :integer
    field :age_25_29, :integer
    field :age_30_34, :integer
    field :age_35_39, :integer
    field :age_40_44, :integer
    field :age_45_49, :integer
    field :age_50_54, :integer
    field :age_55_59, :integer
    field :age_60_64, :integer
    field :age_64_69, :integer
    field :age_70_74, :integer
    field :age_75_79, :integer
    field :age_80_or_more, :integer

    belongs_to :health_region, Geo.HealthRegion
  end

  @cast_attrs [
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
    :age_80_or_more,
    :health_region_id
  ]

  @doc false
  @spec changeset(%HealthRegionPopulation{}, map()) :: Ecto.Changeset.t()
  def changeset(health_region_population, attrs) do
    health_region_population
    |> cast(attrs, @cast_attrs)
    |> validate_required(@cast_attrs)
    |> unique_constraint([:year, :health_region_id])
  end
end
