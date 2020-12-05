defmodule HealthBoard.Release.DataManager.YearlyPopulations do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "demographic"
  @table_name "yearly_populations"
  @columns [
    :location_id,
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
    :age_65_69,
    :age_70_74,
    :age_75_79,
    :age_80_or_more
  ]

  @spec up :: :ok
  def up do
    DataManager.copy!(@context, @table_name, @columns)
  end

  @spec down :: :ok
  def down do
    Repo.query!("TRUNCATE #{@table_name} CASCADE;")
    :ok
  end
end
