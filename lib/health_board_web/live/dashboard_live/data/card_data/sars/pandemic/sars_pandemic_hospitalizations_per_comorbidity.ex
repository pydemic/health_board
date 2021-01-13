defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicHospitalizationsPerComorbidity do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :vertical_bar}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      },
      last_record_date: data.last_record_date
    }
  end

  @labels [
    "Asma",
    "Doença cardiovascular crônica",
    "Doença hematológica crônica",
    "Doença renal crônica",
    "Doença hepática crônica",
    "Doença neurológica crônica",
    "Doença pneumatopatia crônica",
    "Diabetes Mellitus",
    "Síndrome de Down",
    "Imunodeficiência ou imunodepressão",
    "Obesidade",
    "Puérpera"
  ]

  @fields [
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

  defp do_fetch(data) do
    %{symptoms: symptoms} = data

    %{
      id: data.section_card_id,
      labels: @labels,
      label: "Internações",
      data: Enum.map(@fields, &Map.get(symptoms, &1, 0))
    }
  end
end
