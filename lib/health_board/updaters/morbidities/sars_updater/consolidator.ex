defmodule HealthBoard.Updaters.SARSUpdater.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Consolidations.ConsolidationsGroups
  alias HealthBoard.Contexts.Geo.Locations

  @first_case_date Date.from_erl!({2020, 02, 26})

  @confirmed_index 2
  @female_index 3

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

  @discarded_index @ignored_race + 1

  @sample_index @discarded_index + 1

  @first_symptom_index @ignored_race + 1

  @ets_cities :sars_updater__cities

  @ets_consolidations_groups :sars_updater__consolidations_groups
  @ets_daily_locations_buckets :sars_updater__daily_consolidations
  @ets_weekly_locations_buckets :sars_updater__weekly_consolidations
  @ets_monthly_locations_buckets :sars_updater__monthly_consolidations
  @ets_yearly_locations_buckets :sars_updater__yearly_consolidations
  @ets_locations_buckets :sars_updater__locations_consolidations
  @ets_locations_dates_buckets :sars_updater__locations_dates

  @confirmed_cases_group_name "morbidities_sars_residence_confirmed_cases"
  @discarded_cases_group_name "morbidities_sars_residence_discarded_cases"
  @cases_per_age_gender_group_name "morbidities_sars_residence_cases_per_age_gender"
  @cases_per_race_group_name "morbidities_sars_residence_cases_per_race"

  @samples_group_name "morbidities_sars_residence_samples"

  @deaths_group_name "morbidities_sars_residence_deaths"
  @deaths_per_age_gender_group_name "morbidities_sars_residence_deaths_per_age_gender"
  @deaths_per_race_group_name "morbidities_sars_residence_deaths_per_race"

  @hospitalizations_group_name "morbidities_sars_residence_hospitalizations"
  @hospitalizations_per_age_gender_group_name "morbidities_sars_residence_hospitalizations_per_age_gender"
  @hospitalizations_per_race_group_name "morbidities_sars_residence_hospitalizations_per_race"
  @hospitalizations_per_symptom_group_name "morbidities_sars_residence_hospitalizations_per_symptom"
  @hospitalizations_per_comorbidity_group_name "morbidities_sars_residence_hospitalizations_per_comorbidity"

  @group_names {@confirmed_cases_group_name, @discarded_cases_group_name, @cases_per_age_gender_group_name,
                @cases_per_race_group_name, @samples_group_name, @deaths_group_name, @deaths_per_age_gender_group_name,
                @deaths_per_race_group_name, @hospitalizations_group_name, @hospitalizations_per_age_gender_group_name,
                @hospitalizations_per_race_group_name, @hospitalizations_per_symptom_group_name,
                @hospitalizations_per_comorbidity_group_name}

  @spec consolidate(Enumerable.t(), String.t(), String.t()) :: :ok
  def consolidate(streams, output_path, split_command) do
    Logger.info("Parsing")

    streams
    |> Flow.from_enumerables()
    |> Flow.map(&parse/1)
    |> Flow.run()

    Logger.info("Finished parsing. Writing")

    write(output_path, split_command)

    Logger.info("Finished writing")

    :ok
  end

  defp parse({line, line_index, today}) do
    with {:ok, {classifications, data, symptoms}} <- extract_line_data(line),
         {:ok, data} <- fetch_data(data, today) do
      classifications
      |> fetch_types()
      |> fetch_types_data(data, symptoms)
      |> Enum.each(fn {context, date, locations_ids, counters} ->
        Enum.each(locations_ids, &update_buckets(&1, context, date, counters))
      end)
    end
  rescue
    error ->
      Logger.error("""
      [#{line_index}] #{Exception.message(error)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      #{inspect(line, pretty: true, limit: :infinity, charlists: :as_lists, binaries: :as_strings)}
      """)
  end

  defp extract_line_data(line) do
    [
      notification_date,
      _epidemiological_week,
      symptoms_date,
      _symptoms_epidemiological_week,
      _state_name_notification,
      _regional_name,
      _regional_code,
      _notification_city_name,
      notification_city_id,
      _state_name,
      _state_code_notification,
      gender,
      _date_of_birth,
      age,
      _type_age,
      _age_code,
      _pregnant,
      race,
      _ethnicity,
      _educational_level,
      _country_name,
      _country_code,
      _state,
      _regional_name_residence,
      _regional_code_residence,
      _residence_city_name,
      residence_city_id,
      _district_residence,
      _has_outbreak,
      _nosocomial,
      _has_contact_with_animals,
      symptom_fever,
      symptom_cough,
      symptom_sore_throat,
      symptom_dyspnoea,
      symptom_respiratory_distress,
      symptom_saturation,
      symptom_diarrhea,
      symptom_vomit,
      _other_symptom,
      _other_symptom_unknown,
      comorbidity_puerperal,
      _risk_factor,
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
      _obesity_imc,
      _other_mobidity,
      _morbidity_unknown,
      _vaccine,
      _date_last_vaccine,
      _mother_recived_vaccine,
      _mother_vaccine_date,
      _mother_breastfeed,
      _dt_doseuni,
      _dt_1_dose,
      _dt_2_dose,
      _antiviral,
      _tp_antivir,
      _out_antiv,
      _dt_antivir,
      hospitalization,
      hospitalization_date,
      _sg_uf_inte,
      _id_rg_inte,
      _co_rg_inte,
      _id_mn_inte,
      hospitalization_city_id,
      _uti,
      _dt_entuti,
      _dt_saiduti,
      _suport_ven,
      _raiox_res,
      _raiox_out,
      _dt_raiox,
      sample,
      _dt_coleta,
      _tp_amostra,
      _out_amost,
      _pcr_resul,
      _dt_pcr,
      _pos_pcrflu,
      _tp_flu_pcr,
      _pcr_fluasu,
      _fluasu_out,
      _pcr_flubli,
      _flubli_out,
      _pos_pcrout,
      pcr_vsr,
      pcr_para1,
      pcr_para2,
      pcr_para3,
      pcr_para4,
      pcr_adeno,
      pcr_metap,
      pcr_boca,
      pcr_rino,
      pcr_other,
      _ds_pcr_out,
      final_classification,
      _classi_out,
      _criterio,
      evolution,
      evolution_date,
      _dt_encerra,
      _dt_digita,
      _histo_vgm,
      _pais_vgm,
      _co_ps_vgm,
      _lo_ps_vgm,
      _dt_vgm,
      _dt_rt_vgm,
      pcr_sars2_result,
      _pac_cocbo,
      _pac_dscbo,
      _out_anim,
      symptom_abdominal_pain,
      symptom_fatigue,
      symptom_smell_loss,
      symptom_taste_loss
      | _line
    ] = line

    {
      :ok,
      {
        {hospitalization, evolution, {pcr_sars2_result, final_classification},
         [
           {1, pcr_vsr},
           {2, pcr_para1},
           {3, pcr_para2},
           {4, pcr_para3},
           {5, pcr_para4},
           {6, pcr_adeno},
           {7, pcr_metap},
           {8, pcr_boca},
           {9, pcr_rino},
           {10, pcr_other}
         ]},
        {
          {symptoms_date, notification_date, hospitalization_date, evolution_date},
          {residence_city_id, notification_city_id, hospitalization_city_id},
          sample,
          {age, gender},
          race
        },
        [
          symptom_abdominal_pain,
          symptom_cough,
          symptom_diarrhea,
          symptom_dyspnoea,
          symptom_fatigue,
          symptom_fever,
          symptom_respiratory_distress,
          symptom_saturation,
          symptom_smell_loss,
          symptom_sore_throat,
          symptom_taste_loss,
          symptom_vomit,
          comorbidity_asthma,
          comorbidity_chronic_cardiovascular_disease,
          comorbidity_chronic_hematological_disease,
          comorbidity_chronic_kidney_disease,
          comorbidity_chronic_liver_disease,
          comorbidity_chronic_neurological_disease,
          comorbidity_chronic_pneumatopathy_disease,
          comorbidity_diabetes,
          comorbidity_down_syndrome,
          comorbidity_immunodeficiency,
          comorbidity_obesity,
          comorbidity_puerperal
        ]
      }
    }
  end

  defp fetch_types({hospitalization, evolution, covid, sars}) do
    case validate_type(covid, sars) do
      {:ok, :covid} ->
        [{:confirmed, :covid}]
        |> maybe_append(hospitalization, :hospitalization)
        |> maybe_append(evolution, "2", {:death, :covid})

      {:ok, {:other, indexes}} ->
        cases = Enum.map(indexes, fn index -> {@sample_index + index, 1} end)

        if evolution == "2" do
          [{:confirmed, cases}, {:death, Enum.map(indexes, fn index -> {@ignored_race + index, 1} end)}]
        else
          [{:confirmed, cases}]
        end

      _result ->
        [:discarded]
    end
  end

  defp validate_type(covid, sars) do
    if confirmed_covid?(covid) do
      {:ok, :covid}
    else
      sars
      |> Enum.reduce([], fn
        {index, "1"}, indexes -> [index | indexes]
        _sars_result, indexes -> indexes
      end)
      |> case do
        [] -> :error
        indexes -> {:ok, {:other, indexes}}
      end
    end
  end

  defp confirmed_covid?({pcr_sars2_result, final_classification}),
    do: pcr_sars2_result == "1" or final_classification == "5"

  defp maybe_append(list, input, expected_value \\ "1", element)
  defp maybe_append(list, input, input, element), do: [element | list]
  defp maybe_append(list, _input, _expected_value, _element), do: list

  defp fetch_data({dates, cities_ids, sample, age_gender, race}, today) do
    with {:ok, dates} <- parse_dates(dates, today),
         {:ok, cities_ids} <- parse_cities_ids(cities_ids) do
      {:ok, {dates, cities_ids, parse_sample(sample), parse_age_gender(age_gender), parse_race(race)}}
    end
  end

  defp parse_dates({symptoms_date, notification_date, hospitalization_date, evolution_date}, today) do
    symptoms_date = parse_date(symptoms_date, today)
    notification_date = parse_date(notification_date, today)
    hospitalization_date = parse_date(hospitalization_date, today)
    evolution_date = parse_date(evolution_date, today)

    symptoms_date = symptoms_date || hospitalization_date || evolution_date || notification_date

    if not is_nil(symptoms_date) do
      {
        :ok,
        {
          symptoms_date,
          notification_date || hospitalization_date || evolution_date || symptoms_date,
          hospitalization_date || notification_date || evolution_date || symptoms_date,
          evolution_date || hospitalization_date || notification_date || symptoms_date
        }
      }
    else
      {:error, :invalid_dates}
    end
  end

  defp parse_date(date, today) do
    with [day, month, year] <- Enum.map(String.split(date, "/"), &String.to_integer/1),
         {:ok, date} <- Date.from_erl({year, month, day}),
         true <- Date.compare(@first_case_date, date) != :gt and Date.compare(date, today) != :gt do
      date
    else
      _result -> nil
    end
  rescue
    _error -> nil
  end

  defp parse_cities_ids({residence_city_id, notification_city_id, hospitalization_city_id}) do
    residence_locations_ids = parse_city_id(residence_city_id)
    notification_locations_ids = parse_city_id(notification_city_id)
    hospitalization_locations_ids = parse_city_id(hospitalization_city_id)

    residence_locations_ids = residence_locations_ids || hospitalization_locations_ids || notification_locations_ids

    if not is_nil(residence_locations_ids) do
      {
        :ok,
        {
          residence_locations_ids,
          notification_locations_ids || hospitalization_locations_ids || residence_locations_ids,
          hospitalization_locations_ids || notification_locations_ids || residence_locations_ids
        }
      }
    else
      {:error, :invalid_cities_ids}
    end
  end

  defp parse_city_id(city_id) do
    if city_id != "" do
      case :ets.lookup(@ets_cities, city_id) do
        [{_city_id, locations_ids}] -> locations_ids
        _records -> nil
      end
    else
      nil
    end
  end

  defp parse_sample("1"), do: [{@sample_index, 1}]
  defp parse_sample(_sample), do: []

  defp parse_age_gender({age, gender}) do
    case String.upcase(String.first(gender)) do
      "F" -> parse_age(age, @female_index)
      "M" -> parse_age(age, @male_index)
      _gender -> []
    end
  end

  defp parse_age(age, gender_index) do
    if age != "" do
      age = String.to_integer(age)

      cond do
        age < 0 -> []
        age <= 4 -> [{gender_index + @age_0_4_offset, 1}]
        age <= 9 -> [{gender_index + @age_5_9_offset, 1}]
        age <= 14 -> [{gender_index + @age_10_14_offset, 1}]
        age <= 19 -> [{gender_index + @age_15_19_offset, 1}]
        age <= 24 -> [{gender_index + @age_20_24_offset, 1}]
        age <= 29 -> [{gender_index + @age_25_29_offset, 1}]
        age <= 34 -> [{gender_index + @age_30_34_offset, 1}]
        age <= 39 -> [{gender_index + @age_35_39_offset, 1}]
        age <= 44 -> [{gender_index + @age_40_44_offset, 1}]
        age <= 49 -> [{gender_index + @age_45_49_offset, 1}]
        age <= 54 -> [{gender_index + @age_50_54_offset, 1}]
        age <= 59 -> [{gender_index + @age_55_59_offset, 1}]
        age <= 64 -> [{gender_index + @age_60_64_offset, 1}]
        age <= 69 -> [{gender_index + @age_65_69_offset, 1}]
        age <= 74 -> [{gender_index + @age_70_74_offset, 1}]
        age <= 79 -> [{gender_index + @age_75_79_offset, 1}]
        true -> [{gender_index + @age_80_or_more_offset, 1}]
      end
    else
      []
    end
  rescue
    _error -> []
  end

  defp parse_race(race) do
    case race do
      "1" -> [{@race_caucasian, 1}]
      "2" -> [{@race_african, 1}]
      "3" -> [{@race_asian, 1}]
      "4" -> [{@race_brown, 1}]
      "5" -> [{@race_native, 1}]
      _ -> [{@ignored_race, 1}]
    end
  end

  defp fetch_types_data(types, {dates, locations_ids, sample, age_gender, race}, symptoms) do
    {symptoms_date, notification_date, hospitalization_date, evolution_date} = dates
    {residence_locations_ids, notification_locations_ids, hospitalization_locations_ids} = locations_ids

    age_gender_race = age_gender ++ race

    for type <- types do
      case type do
        {:confirmed, :covid} ->
          {:cases, symptoms_date, residence_locations_ids, [{@confirmed_index, 1} | sample ++ age_gender_race]}

        {:confirmed, counters} ->
          {:cases, symptoms_date, residence_locations_ids, counters}

        :discarded ->
          {:cases, notification_date, notification_locations_ids, [{@discarded_index, 1} | sample]}

        :hospitalization ->
          {:hospitalizations, hospitalization_date, hospitalization_locations_ids,
           [{@confirmed_index, 1} | age_gender_race ++ symptoms_counters(symptoms)]}

        {:death, :covid} ->
          {:deaths, evolution_date, residence_locations_ids, [{@confirmed_index, 1} | age_gender_race]}

        {:death, counters} ->
          {:deaths, evolution_date, residence_locations_ids, counters}
      end
    end
  end

  defp symptoms_counters(symptoms) do
    symptoms
    |> Enum.with_index()
    |> Enum.reduce([], fn {symptom, index}, counters ->
      maybe_append(counters, symptom, {@first_symptom_index + index, 1})
    end)
  end

  defp update_buckets(location_id, context, %{year: year, month: month, day: day}, counters) do
    update_bucket(@ets_daily_locations_buckets, context, {location_id, {year, month, day}}, counters)

    update_bucket(
      @ets_weekly_locations_buckets,
      context,
      {location_id, :calendar.iso_week_number({year, month, day})},
      counters
    )

    update_bucket(@ets_monthly_locations_buckets, context, {location_id, {year, month}}, counters)
    update_bucket(@ets_yearly_locations_buckets, context, {location_id, year}, counters)
    update_bucket(@ets_locations_buckets, context, location_id, counters)
  end

  defp update_bucket(bucket_name, context, key, counters) do
    :ets.update_counter(
      bucket_name,
      {context, key},
      counters,
      new_record(context, key)
    )
  end

  defp new_record(context, key) do
    case context do
      :cases ->
        {{context, key}, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

      :hospitalizations ->
        {{context, key}, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

      :deaths ->
        {{context, key}, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    end
  end

  defp write(dir, split_command) do
    groups_ids = {
      :ets.lookup_element(@ets_consolidations_groups, :confirmed_cases, 2),
      :ets.lookup_element(@ets_consolidations_groups, :discarded_cases, 2),
      :ets.lookup_element(@ets_consolidations_groups, :cases_per_age_gender, 2),
      :ets.lookup_element(@ets_consolidations_groups, :cases_per_race, 2),
      :ets.lookup_element(@ets_consolidations_groups, :samples, 2),
      :ets.lookup_element(@ets_consolidations_groups, :deaths, 2),
      :ets.lookup_element(@ets_consolidations_groups, :deaths_per_age_gender, 2),
      :ets.lookup_element(@ets_consolidations_groups, :deaths_per_race, 2),
      :ets.lookup_element(@ets_consolidations_groups, :hospitalizations, 2),
      :ets.lookup_element(@ets_consolidations_groups, :hospitalizations_per_age_gender, 2),
      :ets.lookup_element(@ets_consolidations_groups, :hospitalizations_per_race, 2),
      :ets.lookup_element(@ets_consolidations_groups, :hospitalizations_per_symptom, 2),
      :ets.lookup_element(@ets_consolidations_groups, :hospitalizations_per_comorbidity, 2)
    }

    [
      write_buckets(@ets_yearly_locations_buckets, dir, :yearly_locations, groups_ids),
      write_buckets(@ets_monthly_locations_buckets, dir, :monthly_locations, groups_ids),
      write_buckets(@ets_weekly_locations_buckets, dir, :weekly_locations, groups_ids),
      write_buckets(@ets_daily_locations_buckets, dir, :daily_locations, groups_ids),
      write_buckets(@ets_locations_buckets, dir, :locations, groups_ids)
    ]
    |> Enum.each(fn files -> Enum.each(files, &sort_and_chunk_file(&1, split_command)) end)
  end

  defp write_buckets(bucket_name, dir, consolidation_type, groups_ids) do
    Logger.info("Writing #{bucket_name}")

    records = :ets.tab2list(bucket_name)
    :ets.delete_all_objects(bucket_name)

    records
    |> Enum.reduce(Enum.map(0..12, fn _ -> [] end), &to_lines(consolidation_type, &1, &2, groups_ids))
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      write_lines(line, dir, consolidation_type, elem(groups_ids, index), elem(@group_names, index))
    end)
  end

  defp write_lines(lines, dir, consolidation_type, group_id, group_name) do
    file_path = Path.join(dir, "consolidations/#{consolidation_type}_consolidations/#{group_id}_#{group_name}.csv")

    lines
    |> Enum.join("\n")
    |> write_to_file(file_path)

    file_path
  end

  defp write_to_file(content, file_path) do
    File.rm_rf!(file_path)
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, content)
  end

  defp to_lines(consolidation_type, record, lines, groups_ids) do
    case elem(elem(record, 0), 0) do
      :cases -> to_cases_lines(record, consolidation_type, lines, groups_ids)
      :deaths -> to_deaths_lines(record, consolidation_type, lines, groups_ids)
      :hospitalizations -> to_hospitalizations_lines(record, consolidation_type, lines, groups_ids)
    end
  end

  defp to_cases_lines(record, consolidation_type, lines, groups_ids) do
    {
      {context, record_key},
      confirmed_cases,
      female_0_4_cases,
      female_5_9_cases,
      female_10_14_cases,
      female_15_19_cases,
      female_20_24_cases,
      female_25_29_cases,
      female_30_34_cases,
      female_35_39_cases,
      female_40_44_cases,
      female_45_49_cases,
      female_50_54_cases,
      female_55_59_cases,
      female_60_64_cases,
      female_65_69_cases,
      female_70_74_cases,
      female_75_79_cases,
      female_80_or_more_cases,
      male_0_4_cases,
      male_5_9_cases,
      male_10_14_cases,
      male_15_19_cases,
      male_20_24_cases,
      male_25_29_cases,
      male_30_34_cases,
      male_35_39_cases,
      male_40_44_cases,
      male_45_49_cases,
      male_50_54_cases,
      male_55_59_cases,
      male_60_64_cases,
      male_65_69_cases,
      male_70_74_cases,
      male_75_79_cases,
      male_80_or_more_cases,
      caucasian_cases,
      african_cases,
      asian_cases,
      brown_cases,
      native_cases,
      ignored_race_cases,
      discarded_cases,
      sample_cases,
      vsr_cases,
      para1_cases,
      para2_cases,
      para3_cases,
      para4_cases,
      adeno_cases,
      metap_cases,
      boca_cases,
      rino_cases,
      other_cases
    } = record

    update_lines(
      consolidation_type,
      context,
      record_key,
      lines,
      groups_ids,
      [
        {0,
         {confirmed_cases,
          [
            vsr_cases,
            para1_cases,
            para2_cases,
            para3_cases,
            para4_cases,
            adeno_cases,
            metap_cases,
            boca_cases,
            rino_cases,
            other_cases
          ]}},
        {1, discarded_cases},
        {2,
         [
           female_0_4_cases,
           female_5_9_cases,
           female_10_14_cases,
           female_15_19_cases,
           female_20_24_cases,
           female_25_29_cases,
           female_30_34_cases,
           female_35_39_cases,
           female_40_44_cases,
           female_45_49_cases,
           female_50_54_cases,
           female_55_59_cases,
           female_60_64_cases,
           female_65_69_cases,
           female_70_74_cases,
           female_75_79_cases,
           female_80_or_more_cases,
           male_0_4_cases,
           male_5_9_cases,
           male_10_14_cases,
           male_15_19_cases,
           male_20_24_cases,
           male_25_29_cases,
           male_30_34_cases,
           male_35_39_cases,
           male_40_44_cases,
           male_45_49_cases,
           male_50_54_cases,
           male_55_59_cases,
           male_60_64_cases,
           male_65_69_cases,
           male_70_74_cases,
           male_75_79_cases,
           male_80_or_more_cases
         ]},
        {3, [caucasian_cases, african_cases, asian_cases, brown_cases, native_cases, ignored_race_cases]},
        {4, sample_cases}
      ]
    )
  end

  defp to_deaths_lines(record, consolidation_type, lines, groups_ids) do
    {
      {context, record_key},
      deaths,
      female_0_4_deaths,
      female_5_9_deaths,
      female_10_14_deaths,
      female_15_19_deaths,
      female_20_24_deaths,
      female_25_29_deaths,
      female_30_34_deaths,
      female_35_39_deaths,
      female_40_44_deaths,
      female_45_49_deaths,
      female_50_54_deaths,
      female_55_59_deaths,
      female_60_64_deaths,
      female_65_69_deaths,
      female_70_74_deaths,
      female_75_79_deaths,
      female_80_or_more_deaths,
      male_0_4_deaths,
      male_5_9_deaths,
      male_10_14_deaths,
      male_15_19_deaths,
      male_20_24_deaths,
      male_25_29_deaths,
      male_30_34_deaths,
      male_35_39_deaths,
      male_40_44_deaths,
      male_45_49_deaths,
      male_50_54_deaths,
      male_55_59_deaths,
      male_60_64_deaths,
      male_65_69_deaths,
      male_70_74_deaths,
      male_75_79_deaths,
      male_80_or_more_deaths,
      caucasian_deaths,
      african_deaths,
      asian_deaths,
      brown_deaths,
      native_deaths,
      ignored_race_deaths,
      vsr_deaths,
      para1_deaths,
      para2_deaths,
      para3_deaths,
      para4_deaths,
      adeno_deaths,
      metap_deaths,
      boca_deaths,
      rino_deaths,
      other_deaths
    } = record

    update_lines(
      consolidation_type,
      context,
      record_key,
      lines,
      groups_ids,
      [
        {5,
         {deaths,
          [
            vsr_deaths,
            para1_deaths,
            para2_deaths,
            para3_deaths,
            para4_deaths,
            adeno_deaths,
            metap_deaths,
            boca_deaths,
            rino_deaths,
            other_deaths
          ]}},
        {6,
         [
           female_0_4_deaths,
           female_5_9_deaths,
           female_10_14_deaths,
           female_15_19_deaths,
           female_20_24_deaths,
           female_25_29_deaths,
           female_30_34_deaths,
           female_35_39_deaths,
           female_40_44_deaths,
           female_45_49_deaths,
           female_50_54_deaths,
           female_55_59_deaths,
           female_60_64_deaths,
           female_65_69_deaths,
           female_70_74_deaths,
           female_75_79_deaths,
           female_80_or_more_deaths,
           male_0_4_deaths,
           male_5_9_deaths,
           male_10_14_deaths,
           male_15_19_deaths,
           male_20_24_deaths,
           male_25_29_deaths,
           male_30_34_deaths,
           male_35_39_deaths,
           male_40_44_deaths,
           male_45_49_deaths,
           male_50_54_deaths,
           male_55_59_deaths,
           male_60_64_deaths,
           male_65_69_deaths,
           male_70_74_deaths,
           male_75_79_deaths,
           male_80_or_more_deaths
         ]},
        {7, [caucasian_deaths, african_deaths, asian_deaths, brown_deaths, native_deaths, ignored_race_deaths]}
      ]
    )
  end

  defp to_hospitalizations_lines(record, consolidation_type, lines, groups_ids) do
    {
      {context, record_key},
      hospitalizations,
      female_0_4_hospitalizations,
      female_5_9_hospitalizations,
      female_10_14_hospitalizations,
      female_15_19_hospitalizations,
      female_20_24_hospitalizations,
      female_25_29_hospitalizations,
      female_30_34_hospitalizations,
      female_35_39_hospitalizations,
      female_40_44_hospitalizations,
      female_45_49_hospitalizations,
      female_50_54_hospitalizations,
      female_55_59_hospitalizations,
      female_60_64_hospitalizations,
      female_65_69_hospitalizations,
      female_70_74_hospitalizations,
      female_75_79_hospitalizations,
      female_80_or_more_hospitalizations,
      male_0_4_hospitalizations,
      male_5_9_hospitalizations,
      male_10_14_hospitalizations,
      male_15_19_hospitalizations,
      male_20_24_hospitalizations,
      male_25_29_hospitalizations,
      male_30_34_hospitalizations,
      male_35_39_hospitalizations,
      male_40_44_hospitalizations,
      male_45_49_hospitalizations,
      male_50_54_hospitalizations,
      male_55_59_hospitalizations,
      male_60_64_hospitalizations,
      male_65_69_hospitalizations,
      male_70_74_hospitalizations,
      male_75_79_hospitalizations,
      male_80_or_more_hospitalizations,
      caucasian_hospitalizations,
      african_hospitalizations,
      asian_hospitalizations,
      brown_hospitalizations,
      native_hospitalizations,
      ignored_race_hospitalizations,
      symptom_abdominal_pain,
      symptom_cough,
      symptom_diarrhea,
      symptom_dyspnoea,
      symptom_fatigue,
      symptom_fever,
      symptom_respiratory_distress,
      symptom_saturation,
      symptom_smell_loss,
      symptom_sore_throat,
      symptom_taste_loss,
      symptom_vomit,
      comorbidity_asthma,
      comorbidity_chronic_cardiovascular_disease,
      comorbidity_chronic_hematological_disease,
      comorbidity_chronic_kidney_disease,
      comorbidity_chronic_liver_disease,
      comorbidity_chronic_neurological_disease,
      comorbidity_chronic_pneumatopathy_disease,
      comorbidity_diabetes,
      comorbidity_down_syndrome,
      comorbidity_immunodeficiency,
      comorbidity_obesity,
      comorbidity_puerperal
    } = record

    update_lines(
      consolidation_type,
      context,
      record_key,
      lines,
      groups_ids,
      [
        {8, hospitalizations},
        {9,
         [
           female_0_4_hospitalizations,
           female_5_9_hospitalizations,
           female_10_14_hospitalizations,
           female_15_19_hospitalizations,
           female_20_24_hospitalizations,
           female_25_29_hospitalizations,
           female_30_34_hospitalizations,
           female_35_39_hospitalizations,
           female_40_44_hospitalizations,
           female_45_49_hospitalizations,
           female_50_54_hospitalizations,
           female_55_59_hospitalizations,
           female_60_64_hospitalizations,
           female_65_69_hospitalizations,
           female_70_74_hospitalizations,
           female_75_79_hospitalizations,
           female_80_or_more_hospitalizations,
           male_0_4_hospitalizations,
           male_5_9_hospitalizations,
           male_10_14_hospitalizations,
           male_15_19_hospitalizations,
           male_20_24_hospitalizations,
           male_25_29_hospitalizations,
           male_30_34_hospitalizations,
           male_35_39_hospitalizations,
           male_40_44_hospitalizations,
           male_45_49_hospitalizations,
           male_50_54_hospitalizations,
           male_55_59_hospitalizations,
           male_60_64_hospitalizations,
           male_65_69_hospitalizations,
           male_70_74_hospitalizations,
           male_75_79_hospitalizations,
           male_80_or_more_hospitalizations
         ]},
        {10,
         [
           caucasian_hospitalizations,
           african_hospitalizations,
           asian_hospitalizations,
           brown_hospitalizations,
           native_hospitalizations,
           ignored_race_hospitalizations
         ]},
        {11,
         [
           symptom_abdominal_pain,
           symptom_cough,
           symptom_diarrhea,
           symptom_dyspnoea,
           symptom_fatigue,
           symptom_fever,
           symptom_respiratory_distress,
           symptom_saturation,
           symptom_smell_loss,
           symptom_sore_throat,
           symptom_taste_loss,
           symptom_vomit
         ]},
        {12,
         [
           comorbidity_asthma,
           comorbidity_chronic_cardiovascular_disease,
           comorbidity_chronic_hematological_disease,
           comorbidity_chronic_kidney_disease,
           comorbidity_chronic_liver_disease,
           comorbidity_chronic_neurological_disease,
           comorbidity_chronic_pneumatopathy_disease,
           comorbidity_diabetes,
           comorbidity_down_syndrome,
           comorbidity_immunodeficiency,
           comorbidity_obesity,
           comorbidity_puerperal
         ]}
      ]
    )
  end

  defp update_lines(consolidation_type, context, record_key, lines, groups_ids, updates) do
    key_string = parse_record_key(consolidation_type, record_key)

    if consolidation_type == :locations do
      Enum.reduce(updates, lines, fn {index, value}, lines ->
        [{_key, from, to}] = :ets.lookup(@ets_locations_dates_buckets, {context, index, record_key})

        case value do
          {0, list} ->
            if Enum.any?(list, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join([elem(groups_ids, index), key_string, nil, ~s'"#{Enum.join(list, ",")}"', from, to], ",")
                  | &1
                ]
              )
            else
              lines
            end

          {integer, list} ->
            if Enum.any?(list, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join(
                    [elem(groups_ids, index), key_string, integer, ~s'"#{Enum.join(list, ",")}"', from, to],
                    ","
                  )
                  | &1
                ]
              )
            else
              List.update_at(
                lines,
                index,
                &[Enum.join([elem(groups_ids, index), key_string, integer, nil, from, to], ",") | &1]
              )
            end

          list when is_list(list) ->
            if Enum.any?(value, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join([elem(groups_ids, index), key_string, nil, ~s'"#{Enum.join(value, ",")}"', from, to], ",")
                  | &1
                ]
              )
            else
              lines
            end

          integer ->
            if integer > 0 do
              List.update_at(
                lines,
                index,
                &[Enum.join([elem(groups_ids, index), key_string, integer, nil, from, to], ",") | &1]
              )
            else
              lines
            end
        end
      end)
    else
      Enum.reduce(updates, lines, fn {index, value}, lines ->
        if consolidation_type == :daily_locations do
          location_bucket_date(context, index, record_key)
        end

        case value do
          {0, list} ->
            if Enum.any?(list, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join([elem(groups_ids, index), key_string, nil, ~s'"#{Enum.join(list, ",")}"'], ",")
                  | &1
                ]
              )
            else
              lines
            end

          {integer, list} ->
            if Enum.any?(list, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join([elem(groups_ids, index), key_string, integer, ~s'"#{Enum.join(list, ",")}"'], ",")
                  | &1
                ]
              )
            else
              List.update_at(
                lines,
                index,
                &[Enum.join([elem(groups_ids, index), key_string, integer, nil], ",") | &1]
              )
            end

          list when is_list(list) ->
            if Enum.any?(list, &(&1 > 0)) do
              List.update_at(
                lines,
                index,
                &[
                  Enum.join([elem(groups_ids, index), key_string, nil, ~s'"#{Enum.join(list, ",")}"'], ",")
                  | &1
                ]
              )
            else
              lines
            end

          integer ->
            if integer > 0 do
              List.update_at(
                lines,
                index,
                &[Enum.join([elem(groups_ids, index), key_string, integer, nil], ",") | &1]
              )
            else
              lines
            end
        end
      end)
    end
  end

  defp parse_record_key(consolidation_type, record_key) do
    case {consolidation_type, record_key} do
      {:yearly_locations, {location_id, year}} -> [location_id, year]
      {:monthly_locations, {location_id, {year, month}}} -> [location_id, year, month]
      {:weekly_locations, {location_id, {year, week}}} -> [location_id, year, week]
      {:daily_locations, {location_id, date}} -> [location_id, Date.from_erl!(date)]
      {:locations, location_id} -> [location_id]
    end
    |> Enum.join(",")
  end

  defp location_bucket_date(context, index, {location_id, date}) do
    date = Date.from_erl!(date)

    case :ets.lookup(@ets_locations_dates_buckets, {context, index, location_id}) do
      [{key, from, to}] -> :ets.insert(@ets_locations_dates_buckets, {key, min_date(from, date), max_date(to, date)})
      _result -> :ets.insert(@ets_locations_dates_buckets, {{context, index, location_id}, date, date})
    end
  end

  defp min_date(d1, d2) do
    if Date.compare(d1, d2) == :gt do
      d2
    else
      d1
    end
  end

  defp max_date(d1, d2) do
    if Date.compare(d1, d2) == :lt do
      d2
    else
      d1
    end
  end

  defp sort_and_chunk_file(file_path, split_command) do
    name = Path.basename(file_path, ".csv")

    Logger.info("Sorting and chunking #{name}")

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])

    dir = Path.join(Path.dirname(file_path), name)

    File.rm_rf!(dir)
    File.mkdir_p!(dir)

    {_result, 0} = System.cmd(split_command, ~w[-d -a 4 -l 100000 --additional-suffix=.csv #{file_path} #{dir}/])

    File.rm!(file_path)
  end

  @spec init :: :ok
  def init do
    :ets.new(@ets_cities, [:set, :public, :named_table])

    [group: :cities, preload: :parents]
    |> Locations.list_by()
    |> Enum.each(&:ets.insert_new(@ets_cities, cities_ids(&1)))

    :ets.new(@ets_consolidations_groups, [:set, :public, :named_table])

    :ets.insert_new(@ets_consolidations_groups, [
      {:confirmed_cases, ConsolidationsGroups.fetch_id!(@confirmed_cases_group_name)},
      {:discarded_cases, ConsolidationsGroups.fetch_id!(@discarded_cases_group_name)},
      {:cases_per_age_gender, ConsolidationsGroups.fetch_id!(@cases_per_age_gender_group_name)},
      {:cases_per_race, ConsolidationsGroups.fetch_id!(@cases_per_race_group_name)},
      {:samples, ConsolidationsGroups.fetch_id!(@samples_group_name)},
      {:deaths, ConsolidationsGroups.fetch_id!(@deaths_group_name)},
      {:deaths_per_age_gender, ConsolidationsGroups.fetch_id!(@deaths_per_age_gender_group_name)},
      {:deaths_per_race, ConsolidationsGroups.fetch_id!(@deaths_per_race_group_name)},
      {:hospitalizations, ConsolidationsGroups.fetch_id!(@hospitalizations_group_name)},
      {:hospitalizations_per_age_gender, ConsolidationsGroups.fetch_id!(@hospitalizations_per_age_gender_group_name)},
      {:hospitalizations_per_race, ConsolidationsGroups.fetch_id!(@hospitalizations_per_race_group_name)},
      {:hospitalizations_per_symptom, ConsolidationsGroups.fetch_id!(@hospitalizations_per_symptom_group_name)},
      {:hospitalizations_per_comorbidity, ConsolidationsGroups.fetch_id!(@hospitalizations_per_comorbidity_group_name)}
    ])

    :ets.new(@ets_daily_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_weekly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_monthly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_yearly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_locations_buckets, [:set, :public, :named_table])

    :ets.new(@ets_locations_dates_buckets, [:set, :public, :named_table])

    :ok
  end

  defp cities_ids(%{id: city_id} = location) do
    {
      Integer.to_string(div(city_id, 10)),
      [
        city_id,
        Locations.parent(location, :health_regions).id,
        Locations.parent(location, :states).id,
        Locations.parent(location, :regions).id,
        76
      ]
    }
  end

  @spec setup :: :ok
  def setup do
    :ets.delete_all_objects(@ets_locations_dates_buckets)

    :ets.delete_all_objects(@ets_locations_buckets)
    :ets.delete_all_objects(@ets_yearly_locations_buckets)
    :ets.delete_all_objects(@ets_monthly_locations_buckets)
    :ets.delete_all_objects(@ets_weekly_locations_buckets)
    :ets.delete_all_objects(@ets_daily_locations_buckets)

    :ok
  end

  @spec shutdown :: :ok
  def shutdown do
    :ets.delete(@ets_cities)

    :ets.delete(@ets_consolidations_groups)

    :ets.delete(@ets_locations_buckets)
    :ets.delete(@ets_yearly_locations_buckets)
    :ets.delete(@ets_monthly_locations_buckets)
    :ets.delete(@ets_weekly_locations_buckets)
    :ets.delete(@ets_daily_locations_buckets)

    :ets.delete(@ets_locations_dates_buckets)

    :ok
  end
end
