defmodule HealthBoard.Release.DataManager.PandemicSARSSymptoms do
  alias HealthBoard.Release.DataManager
  alias HealthBoard.Repo

  @context "sars"
  @table_name "pandemic_sars_symptoms"
  @columns [
    :context,
    :location_id,
    :symptom_abdominal_pain,
    :symptom_cough,
    :symptom_diarrhea,
    :symptom_dyspnoea,
    :symptom_fatigue,
    :symptom_fever,
    :symptom_respiratory_distress,
    :symptom_saturation,
    :symptom_smell_loss,
    :symptom_sore_throat,
    :symptom_taste_loss,
    :symptom_vomit,
    :comorbidity_asthma,
    :comorbidity_chronic_cardiovascular_disease,
    :comorbidity_chronic_hematological_disease,
    :comorbidity_chronic_kidney_disease,
    :comorbidity_chronic_liver_disease,
    :comorbidity_chronic_neurological_disease,
    :comorbidity_chronic_pneumatopathy_disease,
    :comorbidity_diabetes,
    :comorbidity_down_syndrome,
    :comorbidity_immunodeficiency,
    :comorbidity_obesity,
    :comorbidity_puerperal
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
