defmodule HealthBoard.Repo.Migrations.CreateMorbiditiesAndMortalities do
  use Ecto.Migration

  def change do
    create table(:weekly_deaths), do: weekly_deaths()
    create table(:weekly_morbidities), do: weekly_morbidities()
    create table(:yearly_deaths), do: yearly_deaths()
    create table(:yearly_morbidities), do: yearly_morbidities()
  end

  defp weekly_deaths do
    week()
    yearly_deaths()
  end

  defp weekly_morbidities do
    week()
    yearly_morbidities()
  end

  defp yearly_deaths do
    common_columns()

    add :fetal, :integer, default: 0
    add :non_fetal, :integer, default: 0
    add :ignored_type, :integer, default: 0

    add :investigated, :integer, default: 0
    add :not_investigated, :integer, default: 0
    add :ignored_investigation, :integer, default: 0
  end

  defp yearly_morbidities do
    common_columns()

    add :confirmed, :integer, default: 0
    add :discarded, :integer, default: 0
    add :ignored_classification, :integer, default: 0

    add :healed, :integer, default: 0
    add :died_from_morbidity, :integer, default: 0
    add :died_from_other_causes, :integer, default: 0
    add :ignored_evolution, :integer, default: 0
  end

  defp week do
    add :week, :integer, default: 0
  end

  defp common_columns do
    add :context, :integer, null: false

    add :year, :integer, null: false

    add :total, :integer, null: false

    add :female_0_4, :integer, default: 0
    add :female_5_9, :integer, default: 0
    add :female_10_14, :integer, default: 0
    add :female_15_19, :integer, default: 0
    add :female_20_24, :integer, default: 0
    add :female_25_29, :integer, default: 0
    add :female_30_34, :integer, default: 0
    add :female_35_39, :integer, default: 0
    add :female_40_44, :integer, default: 0
    add :female_45_49, :integer, default: 0
    add :female_50_54, :integer, default: 0
    add :female_55_59, :integer, default: 0
    add :female_60_64, :integer, default: 0
    add :female_65_69, :integer, default: 0
    add :female_70_74, :integer, default: 0
    add :female_75_79, :integer, default: 0
    add :female_80_or_more, :integer, default: 0

    add :male_0_4, :integer, default: 0
    add :male_5_9, :integer, default: 0
    add :male_10_14, :integer, default: 0
    add :male_15_19, :integer, default: 0
    add :male_20_24, :integer, default: 0
    add :male_25_29, :integer, default: 0
    add :male_30_34, :integer, default: 0
    add :male_35_39, :integer, default: 0
    add :male_40_44, :integer, default: 0
    add :male_45_49, :integer, default: 0
    add :male_50_54, :integer, default: 0
    add :male_55_59, :integer, default: 0
    add :male_60_64, :integer, default: 0
    add :male_65_69, :integer, default: 0
    add :male_70_74, :integer, default: 0
    add :male_75_79, :integer, default: 0
    add :male_80_or_more, :integer, default: 0

    add :ignored_age_gender, :integer, default: 0

    add :race_caucasian, :integer, default: 0
    add :race_african, :integer, default: 0
    add :race_asian, :integer, default: 0
    add :race_brown, :integer, default: 0
    add :race_native, :integer, default: 0
    add :ignored_race, :integer, default: 0

    add :location_id, references(:locations, on_delete: :delete_all), null: false
  end
end
