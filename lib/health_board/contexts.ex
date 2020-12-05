defmodule HealthBoard.Contexts do
  @data_contexts %{
    births: 1_000_000,
    morbidity: 2_000_000,
    deaths: 3_000_000
  }

  @spec data_context!(integer, atom) :: integer
  def data_context!(value \\ 0, key), do: Map.fetch!(@data_contexts, key) + value

  @spec fetch!(integer, list(atom), keyword) :: integer
  def fetch!(value \\ 0, contexts, keys) do
    contexts
    |> Enum.map(&Keyword.get(keys, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(value, &fetch_context!(&2, elem(&1, 0), elem(&1, 1)))
  end

  @functions %{
    context: :context!,
    geographic_location: :geographic_location!,
    morbidity: :morbidity!,
    mortality: :mortality!,
    registry_location: :registry_location!
  }

  defp fetch_context!(value, context, key) do
    apply(__MODULE__, Map.fetch!(@functions, context), [value, key])
  end

  @geographic_locations %{
    country: 0,
    region: 1,
    state: 2,
    health_region: 3,
    city: 4
  }

  @spec geographic_location!(integer, atom) :: integer
  def geographic_location!(value \\ 0, key), do: Map.fetch!(@geographic_locations, key) + value

  @morbidities %{
    botulism: 100_000,
    cholera: 100_100,
    anthrax: 100_200,
    tularemia: 100_300,
    smallpox: 100_400,
    arenavirus: 100_500,
    ebola: 100_600,
    marburg: 100_700,
    lassa: 100_800,
    brazilian_purpuric_fever: 100_900,
    threatening_public_health_event: 101_000,
    severe_adverse_vaccination_effect: 101_100,
    yellow_fever: 101_200,
    west_nile_fever: 101_300,
    spotted_fever: 101_400,
    hantavirus: 101_500,
    human_influenzae: 101_600,
    extra_amazon_malaria: 101_700,
    polio: 101_800,
    plague: 101_900,
    human_rabies: 102_000,
    congenital_rubella_syndrome: 102_100,
    measle: 102_200,
    rubella: 102_300,
    acute_flaccid_paralysis: 102_400,
    sars_cov: 102_500,
    mers_cov: 102_600,
    dengue: 110_000,
    zika: 110_100,
    chikungunya: 110_200,
    coqueluche: 200_000,
    diphtheria: 200_100,
    acute_chagas_disease: 200_200,
    haemophilus_influenzae: 200_300,
    meningococcal_disease: 200_400,
    typhoid_fever: 200_500,
    varicella: 200_600,
    severe_work_accident: 300_000,
    accident_by_venomous_animals: 300_100,
    rabies_related_animals_disease: 300_200,
    leptospirosis: 300_300,
    accidental_tetanus: 300_400,
    neonatal_tetanus: 300_500,
    sexual_violence: 300_600,
    suicide: 300_700,
    violence: 300_800,
    bio_exposure_work_accident: 410_000,
    chronic_chagas_disease: 410_100,
    creutzfeldt_jakob_disease: 410_200,
    schistosomiasis: 410_300,
    leprosy: 410_400,
    viral_hepatitis: 410_500,
    hiv: 410_600,
    exogenous_intoxication: 410_700,
    american_cutaneous_leishmaniasis: 410_800,
    visceral_leishmaniasis: 410_900,
    amazon_malaria: 411_000,
    infant_death: 411_100,
    maternal_death: 411_200,
    syphilis: 411_300,
    congenital_pregnant_toxoplasmosis: 411_400,
    tuberculosis: 411_500,
    domestic_violence: 411_600,
    transport_accident: 411_700
  }

  @spec morbidity!(integer, atom) :: integer
  def morbidity!(value \\ 0, key), do: Map.fetch!(@morbidities, key) + value

  @spec mortality!(integer, atom) :: integer
  def mortality!(value \\ 0, key), do: morbidity!(value, key)

  @registry_locations %{
    residence: 0,
    notification: 1
  }

  @spec registry_location!(integer, atom) :: integer
  def registry_location!(value \\ 0, key), do: Map.fetch!(@registry_locations, key) + value
end
