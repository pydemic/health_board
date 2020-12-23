defmodule HealthBoard.Repo.Migrations.CreateSARS do
  use Ecto.Migration

  def change do
    create_pandemic_sars_symptoms()
    create_pandemic_sars_cases()
    create_monthly_sars_cases()
    create_weekly_sars_cases()
    create_daily_sars_cases()
  end

  defp create_pandemic_sars_symptoms do
    create table(:pandemic_sars_symptoms) do
      add :context, :integer, null: false

      add :symptom_abdominal_pain, :integer, default: 0
      add :symptom_cough, :integer, default: 0
      add :symptom_diarrhea, :integer, default: 0
      add :symptom_dyspnoea, :integer, default: 0
      add :symptom_fatigue, :integer, default: 0
      add :symptom_fever, :integer, default: 0
      add :symptom_respiratory_distress, :integer, default: 0
      add :symptom_saturation, :integer, default: 0
      add :symptom_smell_loss, :integer, default: 0
      add :symptom_sore_throat, :integer, default: 0
      add :symptom_taste_loss, :integer, default: 0
      add :symptom_vomit, :integer, default: 0

      add :comorbidity_asthma, :integer, default: 0
      add :comorbidity_chronic_cardiovascular_disease, :integer, default: 0
      add :comorbidity_chronic_hematological_disease, :integer, default: 0
      add :comorbidity_chronic_kidney_disease, :integer, default: 0
      add :comorbidity_chronic_liver_disease, :integer, default: 0
      add :comorbidity_chronic_neurological_disease, :integer, default: 0
      add :comorbidity_chronic_pneumatopathy_disease, :integer, default: 0
      add :comorbidity_diabetes, :integer, default: 0
      add :comorbidity_down_syndrome, :integer, default: 0
      add :comorbidity_immunodeficiency, :integer, default: 0
      add :comorbidity_obesity, :integer, default: 0
      add :comorbidity_puerperal, :integer, default: 0

      add :location_id, references(:locations, on_delete: :delete_all), null: false
    end
  end

  defp create_pandemic_sars_cases do
    create table(:pandemic_sars_cases) do
      common_fields()
    end
  end

  defp create_monthly_sars_cases do
    create table(:monthly_sars_cases) do
      add :year, :integer, null: false
      add :month, :integer, null: false
      common_fields()
    end
  end

  defp create_weekly_sars_cases do
    create table(:weekly_sars_cases) do
      add :year, :integer, null: false
      add :week, :integer, null: false
      common_fields()
    end
  end

  defp create_daily_sars_cases do
    create table(:daily_sars_cases) do
      add :date, :date, null: false
      common_fields()
    end
  end

  defp common_fields do
    add :context, :integer, null: false

    add :confirmed, :integer, default: 0
    add :discarded, :integer, default: 0
    add :samples, :integer, default: 0

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

    add :race_caucasian, :integer, default: 0
    add :race_african, :integer, default: 0
    add :race_asian, :integer, default: 0
    add :race_brown, :integer, default: 0
    add :race_native, :integer, default: 0
    add :ignored_race, :integer, default: 0

    add :location_id, references(:locations, on_delete: :delete_all), null: false
  end
end
