defmodule HealthBoard.Contexts.Demographic.YearPopulation do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "yearly_populations" do
    field :year, :integer

    field :male, :integer, default: 0
    field :female, :integer, default: 0

    field :age_0_4, :integer, default: 0
    field :age_5_9, :integer, default: 0
    field :age_10_14, :integer, default: 0
    field :age_15_19, :integer, default: 0
    field :age_20_24, :integer, default: 0
    field :age_25_29, :integer, default: 0
    field :age_30_34, :integer, default: 0
    field :age_35_39, :integer, default: 0
    field :age_40_44, :integer, default: 0
    field :age_45_49, :integer, default: 0
    field :age_50_54, :integer, default: 0
    field :age_55_59, :integer, default: 0
    field :age_60_64, :integer, default: 0
    field :age_65_69, :integer, default: 0
    field :age_70_74, :integer, default: 0
    field :age_75_79, :integer, default: 0
    field :age_80_or_more, :integer, default: 0

    belongs_to :location, Geo.Location

    field :total, :integer, virtual: true
  end

  @spec add_total(schema) :: schema
  def add_total(%__MODULE__{male: male, female: female} = schema) do
    %__MODULE__{schema | total: male + female}
  end
end
