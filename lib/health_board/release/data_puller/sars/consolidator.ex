defmodule HealthBoard.Release.DataPuller.SARS.Consolidator do
  require Logger

  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Geo.Locations

  @first_case_date Date.from_erl!({2020, 02, 26})

  @ets_cities :sars_consolidation_cities

  @ets_daily_buckets :sars_consolidation_daily
  @ets_weekly_buckets :sars_consolidation_weekly
  @ets_monthly_buckets :sars_consolidation_monthly
  @ets_pandemic_buckets :sars_consolidation_pandemic

  @confirmed_index 2
  @discarded_index 3
  @sample_index 4
  @female_index 5

  @age_0_4_offset 0
  @age_5_9_offset 1
  @age_10_14_offset 2
  @age_15_19_offset 3
  @age_20_24_offset 4
  @age_25_29_offset 5
  @age_30_34_offset 6
  @age_35_39_offset 7
  @age_40_44_offset 8
  @age_45_49_offset 9
  @age_50_54_offset 10
  @age_55_59_offset 11
  @age_60_64_offset 12
  @age_65_69_offset 13
  @age_70_74_offset 14
  @age_75_79_offset 15
  @age_80_or_more_offset 16

  @male_index @female_index + @age_80_or_more_offset + 1

  @race_caucasian @male_index + @age_80_or_more_offset + 1
  @race_african @race_caucasian + 1
  @race_asian @race_african + 1
  @race_brown @race_asian + 1
  @race_native @race_brown + 1
  @ignored_race @race_native + 1

  @cases_residence Contexts.registry_location!(:cases_residence)
  @cases_notification Contexts.registry_location!(:cases_notification)
  @deaths_residence Contexts.registry_location!(:deaths_residence)
  @deaths_notification Contexts.registry_location!(:deaths_notification)
  @hospitalizations_residence Contexts.registry_location!(:hospitalizations_residence)
  @hospitalizations_notification Contexts.registry_location!(:hospitalizations_notification)

  @spec setup :: :ok
  def setup do
    :ets.new(@ets_cities, [:set, :public, :named_table])

    [context: Locations.context!(:city)]
    |> Locations.list_by()
    |> Locations.preload_parent(:health_region)
    |> Enum.each(&:ets.insert_new(@ets_cities, locations_ids(&1)))

    :ets.new(@ets_daily_buckets, [:set, :public, :named_table])
    :ets.new(@ets_weekly_buckets, [:set, :public, :named_table])
    :ets.new(@ets_monthly_buckets, [:set, :public, :named_table])
    :ets.new(@ets_pandemic_buckets, [:set, :public, :named_table])

    :ok
  end

  defp locations_ids(%{id: city_id, parents: [%{parent_id: health_region_id}]}) do
    state_id = div(health_region_id, 1_000)
    region_id = div(state_id, 10)

    {
      div(city_id, 10),
      city_id,
      [
        health_region_id,
        state_id,
        region_id
      ]
    }
  end

  @spec parse({integer, String.t(), integer, Date.t(), list(String.t())}) :: :ok
  def parse({file_index, file_name, line_index, today, line}) do
    with {:ok, {dates, cities_ids, classification, gender_age, hospitalization, sample, evolution, race}} <-
           extract_data(line) do
      with {:ok, date} <- identify_date(dates, today),
           {:ok, locations_ids_list} <- identify_locations_ids_list(cities_ids, @cases_residence, @cases_notification) do
        indexes = identify_indexes(classification, gender_age, sample, race)
        Enum.each(locations_ids_list, &update_buckets(&1, date, indexes))
      else
        {:error, error} -> show_error(error, file_index, file_name, line_index)
      end

      with {:ok, :has_hospitalization} <- identify_hospitalization(elem(hospitalization, 0)),
           {:ok, date} <- parse_date(elem(hospitalization, 1), today),
           {:ok, locations_ids_list} <-
             identify_locations_ids_list(
               {elem(hospitalization, 2), elem(hospitalization, 3)},
               @hospitalizations_residence,
               @hospitalizations_notification
             ) do
        indexes = identify_indexes(classification, gender_age, sample, race)
        Enum.each(locations_ids_list, &update_buckets(&1, date, indexes))
      else
        {:error, error} -> show_error(error, file_index, file_name, line_index)
      end

      with {:ok, :has_death} <- identify_death(elem(evolution, 0)),
           {:ok, date} <- parse_date(elem(evolution, 1), today),
           {:ok, locations_ids_list} <-
             identify_locations_ids_list(
               {elem(evolution, 2), elem(evolution, 3)},
               @deaths_residence,
               @deaths_notification
             ) do
        indexes = identify_indexes(classification, gender_age, sample, race)
        Enum.each(locations_ids_list, &update_buckets(&1, date, indexes))
      else
        {:error, error} -> show_error(error, file_index, file_name, line_index)
      end
    else
      {:error, error} -> show_error(error, file_index, file_name, line_index)
    end
  end

  defp extract_data(line) do
    [
      notification_date,
      _SEM_NOT,
      symptoms_date,
      _SEM_PRI,
      _SG_UF_NOT,
      _ID_REGIONA,
      _CO_REGIONA,
      _notification_city_name,
      notification_city_id,
      _ID_UNIDADE,
      _CO_UNI_NOT,
      gender,
      _DT_NASC,
      age,
      _TP_IDADE,
      _COD_IDADE,
      _CS_GESTANT,
      race,
      _CS_ETINIA,
      _CS_ESCOL_N,
      _ID_PAIS,
      _CO_PAIS,
      _SG_UF,
      _ID_RG_RESI,
      _CO_RG_RESI,
      _residence_city_name,
      residence_city_id,
      _CS_ZONA,
      _SURTO_SG,
      _NOSOCOMIAL,
      _AVE_SUINO,
      #
      symptom_fever,
      symptom_cough,
      symptom_sore_throat,
      symptom_dyspnoea,
      symptom_respiratory_distress,
      symptom_saturation,
      symptom_diarrhea,
      symptom_vomit,
      other_symptom,
      _OUTRO_DES,
      comorbidity_puerperal,
      risk_factor,
      comorbidity_chronic_cardiovascular_disease,
      comorbidity_chronic_hematological_disease,
      comorbidity_down_syndrome,
      comorbidity_chronic_liver_disease,
      comorbidity_asthma,
      comorbidity_diabetes,
      comorbidity_chronic_neurological_disease,
      comorbidity_chronic_pneumatopathy_disease,
      comorbidity_immunodeficiency,
      comorbidity_chronic_kidney_disease,
      comorbidity_obesity,
      _OBES_IMC,
      # Existe no mapeamento, mas não foi encaixado
      _other_mobidity,
      _MORB_DESC,
      _VACINA,
      _DT_UT_DOSE,
      _MAE_VAC,
      _DT_VAC_MAE,
      _M_AMAMENTA,
      _DT_DOSEUNI,
      _DT_1_DOSE,
      _DT_2_DOSE,
      _ANTIVIRAL,
      _TP_ANTIVIR,
      _OUT_ANTIV,
      _DT_ANTIVIR,
      hospitalization,
      hospitalization_date,
      _SG_UF_INTE,
      _ID_RG_INTE,
      _CO_RG_INTE,
      _ID_MN_INTE,
      hospitalization_city_id,
      _UTI,
      _DT_ENTUTI,
      _DT_SAIDUTI,
      _SUPORT_VEN,
      _RAIOX_RES,
      _RAIOX_OUT,
      _DT_RAIOX,
      sample,
      _DT_COLETA,
      _TP_AMOSTRA,
      _OUT_AMOST,
      _PCR_RESUL,
      _DT_PCR,
      _POS_PCRFLU,
      _TP_FLU_PCR,
      _PCR_FLUASU,
      _FLUASU_OUT,
      _PCR_FLUBLI,
      _FLUBLI_OUT,
      _POS_PCROUT,
      _PCR_VSR,
      _PCR_PARA1,
      _PCR_PARA2,
      _PCR_PARA3,
      _PCR_PARA4,
      _PCR_ADENO,
      _PCR_METAP,
      _PCR_BOCA,
      _PCR_RINO,
      _PCR_OUTRO,
      _DS_PCR_OUT,
      final_classification,
      _CLASSI_OUT,
      _CRITERIO,
      evolution,
      evolution_date,
      _DT_ENCERRA,
      _DT_DIGITA,
      _HISTO_VGM,
      _PAIS_VGM,
      _CO_PS_VGM,
      _LO_PS_VGM,
      _DT_VGM,
      _DT_RT_VGM,
      pcr_sars2_result,
      _PAC_COCBO,
      _PAC_DSCBO,
      _OUT_ANIM,
      symptom_abdominal_pain,
      symptom_fatigue,
      symptom_smell_loss,
      symptom_taste_loss
      | _line
    ] = line

    {
      :ok,
      {
        {symptoms_date, notification_date},
        {residence_city_id, notification_city_id},
        {pcr_sars2_result, final_classification},
        {gender, age},
        {hospitalization, hospitalization_date, hospitalization_city_id, residence_city_id},
        sample,
        {evolution, evolution_date, residence_city_id, notification_city_id},
        race
      }
    }
  rescue
    error -> {:error, format_error(error, __STACKTRACE__)}
  end

  defp identify_date({symptoms_date, notification_date}, today) do
    case parse_date(symptoms_date, today) do
      {:ok, date} -> {:ok, date}
      _error -> parse_date(notification_date, today)
    end
  end

  defp parse_date(date, today) do
    date =
      date
      |> String.split("/")
      |> Enum.reverse()
      |> Enum.join("-")

    case Date.from_iso8601(date) do
      {:ok, date} ->
        if Date.compare(date, @first_case_date) in [:eq, :gt] and Date.compare(date, today) in [:eq, :lt] do
          {:ok, date}
        else
          {:error, :invalid_date}
        end

      _error ->
        {:error, :invalid_date}
    end
  end

  defp identify_locations_ids_list({residence_city_id, notification_city_id}, residence, notification) do
    if residence_city_id == notification_city_id do
      case identify_locations_ids(residence_city_id) do
        nil -> {:error, :invalid_city_ids}
        locations -> {:ok, [{residence, locations}, {notification, locations}]}
      end
    else
      case {identify_locations_ids(residence_city_id), identify_locations_ids(notification_city_id)} do
        {nil, nil} -> {:error, :invalid_city_ids}
        {locations_ids, nil} -> {:ok, [{residence, locations_ids}]}
        {nil, locations_ids} -> {:ok, [{notification, locations_ids}]}
        {[id | _], [id | _] = locations_ids} -> {:ok, [{residence, locations_ids}, {notification, locations_ids}]}
        {rls, nls} -> {:ok, [{residence, rls}, {notification, nls}]}
      end
    end
  end

  defp identify_locations_ids(city_id) do
    if city_id != "" do
      case :ets.lookup(@ets_cities, String.to_integer(city_id)) do
        [{_city_id_reduced, city_id, locations_ids}] -> [city_id | locations_ids]
        _records -> nil
      end
    else
      nil
    end
  rescue
    _error -> nil
  end

  defp show_error(error, _file_index, _file_name, _line_index) when is_atom(error), do: :ok

  defp show_error(error, file_index, file_name, line_index) do
    Logger.error("[##{file_index} #{file_name}:#{line_index}] #{error}")
  end

  defp identify_hospitalization(hospitalization) do
    if hospitalization != "" do
      case hospitalization do
        "1" -> {:ok, :has_hospitalization}
        _hospitalization -> {:error, nil}
      end
    else
      {:error, nil}
    end
  end

  defp identify_death(evolution) do
    if evolution != "" do
      case evolution do
        "2" -> {:ok, :has_death}
        _hospitalization -> {:error, nil}
      end
    else
      {:error, nil}
    end
  end

  defp identify_indexes(classification, gender_age, sample, race) do
    case identify_classification_index(classification) do
      @confirmed_index ->
        [@confirmed_index]
        |> maybe_add_gender_age_group_index(gender_age)
        |> maybe_add_race_index(race)
        |> maybe_add_sample_index(sample)
        |> Enum.sort()

      @discarded_index ->
        [@discarded_index]
    end
  end

  defp identify_classification_index({test_result, final_classification}) do
    case identify_test_result_index(test_result) do
      @discarded_index -> identify_final_classification_index(final_classification)
      classification -> classification
    end
  end

  defp maybe_add_gender_age_group_index(indexes, {gender, age}) do
    case identify_gender_index(gender) do
      nil ->
        indexes

      gender_index ->
        case identify_age_group_offset(age) do
          nil -> indexes
          age_group_offset -> [gender_index + age_group_offset | indexes]
        end
    end
  end

  defp identify_gender_index(gender) do
    if gender != "" do
      gender
      |> String.first()
      |> String.upcase()
      |> case do
        "F" -> @female_index
        "M" -> @male_index
        _gender -> nil
      end
    else
      nil
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp identify_age_group_offset(age) do
    if age != "" do
      age = String.to_integer(age)

      cond do
        age < 0 -> nil
        age <= 4 -> @age_0_4_offset
        age <= 9 -> @age_5_9_offset
        age <= 14 -> @age_10_14_offset
        age <= 19 -> @age_15_19_offset
        age <= 24 -> @age_20_24_offset
        age <= 29 -> @age_25_29_offset
        age <= 34 -> @age_30_34_offset
        age <= 39 -> @age_35_39_offset
        age <= 44 -> @age_40_44_offset
        age <= 49 -> @age_45_49_offset
        age <= 54 -> @age_50_54_offset
        age <= 59 -> @age_55_59_offset
        age <= 64 -> @age_60_64_offset
        age <= 69 -> @age_65_69_offset
        age <= 74 -> @age_70_74_offset
        age <= 79 -> @age_75_79_offset
        true -> @age_80_or_more_offset
      end
    else
      nil
    end
  rescue
    _error -> nil
  end

  defp identify_test_result_index(test_result) do
    if test_result != "" do
      test_result
      |> String.first()
      |> case do
        "1" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp identify_final_classification_index(final_classification) do
    if final_classification != "" do
      case final_classification do
        "5" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp maybe_add_race_index(indexes, race) do
    case race do
      "1" ->
        [@race_caucasian | indexes]

      "2" ->
        [@race_african | indexes]

      "3" ->
        [@race_asian | indexes]

      "4" ->
        [@race_brown | indexes]

      "5" ->
        [@race_native | indexes]

      _ ->
        indexes
    end
  end

  defp maybe_add_sample_index(indexes, sample) do
    case sample do
      "1" ->
        [@sample_index | indexes]

      _ ->
        indexes
    end
  end

  defp update_buckets({registry_context, locations_ids}, date, indexes) do
    locations = [76 | locations_ids]
    indexes_additions = Enum.map(indexes, &{&1, 1})

    for location_id <- locations, bucket <- buckets_from_date(date) do
      update_bucket(registry_context, bucket, location_id, indexes_additions, indexes)
    end
  end

  defp buckets_from_date(%{year: year, month: month, day: day}) do
    {week_year, week} = :calendar.iso_week_number({year, month, day})

    [
      {@ets_daily_buckets, {year, month, day}},
      {@ets_weekly_buckets, {week_year, week}},
      {@ets_monthly_buckets, {year, month}},
      @ets_pandemic_buckets
    ]
  end

  defp update_bucket(registry_context, bucket, location_id, indexes_additions, indexes) do
    {bucket_name, key} =
      case bucket do
        {bucket_name, date} -> {bucket_name, {registry_context, location_id, date}}
        bucket_name -> {bucket_name, {registry_context, location_id}}
      end

    try do
      :ets.update_counter(bucket_name, key, indexes_additions)
    rescue
      _error ->
        unless :ets.insert_new(bucket_name, new_bucket_record(key, indexes)) do
          :ets.update_counter(bucket_name, key, indexes_additions)
        end
    end
  end

  defp new_bucket_record(key, indexes) do
    {values, _indexes} = Enum.reduce(2..@ignored_race, {[], indexes}, &new_bucket_value/2)
    List.to_tuple([key | Enum.reverse(values)])
  end

  defp new_bucket_value(index, {values, [index | indexes]}), do: {[1 | values], indexes}
  defp new_bucket_value(_index, {values, indexes}), do: {[0 | values], indexes}

  @spec write(String.t()) :: :ok
  def write(dir) do
    write_bucket(@ets_pandemic_buckets, &pandemic_line/1, Path.join(dir, "pandemic_sars_cases.csv"))
    write_bucket(@ets_monthly_buckets, &monthly_line/1, Path.join(dir, "monthly_sars_cases.csv"))
    write_bucket(@ets_weekly_buckets, &weekly_line/1, Path.join(dir, "weekly_sars_cases.csv"))
    write_bucket(@ets_daily_buckets, &daily_line/1, Path.join(dir, "daily_sars_cases.csv"))

    :ok
  end

  defp write_bucket(bucket_name, map_function, file_path) do
    bucket_name
    |> :ets.tab2list()
    |> Enum.map(map_function)
    |> Enum.join("\n")
    |> write_to_file(file_path)

    :ets.delete(bucket_name)
  end

  defp write_to_file(content, file_path) do
    File.write!(file_path, content)
  end

  defp pandemic_line(record) do
    [{registry_context, location_id} | data] = Tuple.to_list(record)
    Enum.join([registry_context, location_id] ++ data, ",")
  end

  defp monthly_line(record) do
    [{registry_context, location_id, {year, month}} | data] = Tuple.to_list(record)
    Enum.join([registry_context, location_id, year, month] ++ data, ",")
  end

  defp weekly_line(record) do
    [{registry_context, location_id, {year, week}} | data] = Tuple.to_list(record)
    Enum.join([registry_context, location_id, year, week] ++ data, ",")
  end

  defp daily_line(record) do
    [{registry_context, location_id, date} | data] = Tuple.to_list(record)
    Enum.join([registry_context, location_id, Date.from_erl!(date)] ++ data, ",")
  end

  defp format_error(error, stacktrace) do
    Exception.message(error) <> "\n" <> Exception.format_stacktrace(stacktrace)
  end
end
