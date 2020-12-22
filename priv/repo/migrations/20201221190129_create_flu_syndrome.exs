defmodule HealthBoard.Repo.Migrations.CreateFluSyndrome do
  use Ecto.Migration

  def change do
    create_pandemic_flu_syndrome_cases()
    create_monthly_flu_syndrome_cases()
    create_weekly_flu_syndrome_cases()
    create_daily_flu_syndrome_cases()
  end

  defp create_pandemic_flu_syndrome_cases do
    create table(:pandemic_flu_syndrome_cases) do
      common_fields()
    end
  end

  defp create_monthly_flu_syndrome_cases do
    create table(:monthly_flu_syndrome_cases) do
      add :year, :integer, null: false
      add :month, :integer, null: false
      common_fields()
    end
  end

  defp create_weekly_flu_syndrome_cases do
    create table(:weekly_flu_syndrome_cases) do
      add :year, :integer, null: false
      add :week, :integer, null: false
      common_fields()
    end
  end

  defp create_daily_flu_syndrome_cases do
    create table(:daily_flu_syndrome_cases) do
      add :date, :date, null: false
      common_fields()
    end
  end

  defp common_fields do
    add :context, :integer, null: false

    add :confirmed, :integer, default: 0
    add :discarded, :integer, default: 0

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

    add :health_professional, :integer, default: 0

    add :location_id, references(:locations, on_delete: :delete_all), null: false
  end
end
