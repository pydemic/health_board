defmodule HealthBoard.Contexts.Seeders.PandemicSARSSymptoms do
  alias HealthBoard.Contexts.Seeder

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

  @spec down! :: :ok
  def down!, do: Seeder.down!(@table_name)

  @spec reseed!(String.t() | nil) :: :ok
  def reseed!(base_path \\ nil) do
    up!(base_path)
    down!()
  end

  @spec up!(String.t() | nil) :: :ok
  def up!(base_path \\ nil), do: Seeder.csvs_from_context!(@context, @table_name, @columns, base_path)
end
