defmodule HealthBoard.Contexts.SARS.SARSSymptoms do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "pandemic_sars_symptoms" do
    field :context, :integer, null: false

    field :symptom_abdominal_pain, :integer, default: 0
    field :symptom_cough, :integer, default: 0
    field :symptom_diarrhea, :integer, default: 0
    field :symptom_dyspnoea, :integer, default: 0
    field :symptom_fatigue, :integer, default: 0
    field :symptom_fever, :integer, default: 0
    field :symptom_respiratory_distress, :integer, default: 0
    field :symptom_saturation, :integer, default: 0
    field :symptom_smell_loss, :integer, default: 0
    field :symptom_sore_throat, :integer, default: 0
    field :symptom_taste_loss, :integer, default: 0
    field :symptom_vomit, :integer, default: 0

    field :comorbidity_asthma, :integer, default: 0
    field :comorbidity_chronic_cardiovascular_disease, :integer, default: 0
    field :comorbidity_chronic_hematological_disease, :integer, default: 0
    field :comorbidity_chronic_kidney_disease, :integer, default: 0
    field :comorbidity_chronic_liver_disease, :integer, default: 0
    field :comorbidity_chronic_neurological_disease, :integer, default: 0
    field :comorbidity_chronic_pneumatopathy_disease, :integer, default: 0
    field :comorbidity_diabetes, :integer, default: 0
    field :comorbidity_down_syndrome, :integer, default: 0
    field :comorbidity_immunodeficiency, :integer, default: 0
    field :comorbidity_obesity, :integer, default: 0
    field :comorbidity_puerperal, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
