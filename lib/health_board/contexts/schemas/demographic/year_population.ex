defmodule HealthBoard.Contexts.Demographic.YearPopulation do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "yearly_populations" do
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
    field :age_65_69, :integer
    field :age_70_74, :integer
    field :age_75_79, :integer
    field :age_80_or_more, :integer

    belongs_to :location, Geo.Location

    field :total, :integer, virtual: true
  end

  @spec add_total(schema) :: schema
  def add_total(%__MODULE__{male: male, female: female} = schema) do
    %__MODULE__{schema | total: male + female}
  end
end
