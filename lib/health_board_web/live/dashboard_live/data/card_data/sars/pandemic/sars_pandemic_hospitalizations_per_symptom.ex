defmodule HealthBoardWeb.DashboardLive.CardData.SarsPandemicHospitalizationsPerSymptom do
  @spec fetch(pid, map, map) :: map
  def fetch(pid, _card, data) do
    Process.send_after(pid, {:exec_and_emit, &do_fetch/1, data, {:chart, :vertical_bar}}, 1_000)

    %{
      filters: %{
        location: data.location_name
      }
    }
  end

  @labels [
    "Dor abdominal",
    "Tosse",
    "Diárreia",
    "Dispneia",
    "Fadiga",
    "Febre",
    "Desconforto respiratório",
    "Saturação oxigênio abaixo de 95%",
    "Perda de olfato",
    "Dor de garganta",
    "Perda de paladar",
    "Vômito"
  ]

  @fields [
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
    :symptom_vomit
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
