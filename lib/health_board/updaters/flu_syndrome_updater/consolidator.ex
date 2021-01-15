defmodule HealthBoard.Updaters.FluSyndromeUpdater.Consolidator do
  require Logger

  alias HealthBoard.Contexts
  alias HealthBoard.Contexts.Geo.Locations

  @first_case_date Date.from_erl!({2020, 02, 26})

  @ets_cities :flu_syndrome_consolidation_cities

  @ets_daily_buckets :flu_syndrome_consolidation_daily
  @ets_weekly_buckets :flu_syndrome_consolidation_weekly
  @ets_monthly_buckets :flu_syndrome_consolidation_monthly
  @ets_pandemic_buckets :flu_syndrome_consolidation_pandemic

  @confirmed_index 2
  @discarded_index 3
  @female_index 4

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
  @health_professional_index @male_index + @age_80_or_more_offset + 1

  @residence Contexts.registry_location!(:residence)
  @notification Contexts.registry_location!(:notification)

  @spec init :: :ok
  def init do
    :ets.new(@ets_cities, [:set, :public, :named_table])

    [context: Locations.context(:city)]
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
    with {:ok, {datetimes, cities_ids, classification, gender_age, is_health_professional}} <- extract_data(line),
         {:ok, date} <- identify_date(datetimes, today),
         {:ok, locations_ids_list} <- identify_locations_ids_list(cities_ids) do
      indexes = identify_indexes(classification, gender_age, is_health_professional)
      Enum.each(locations_ids_list, &update_buckets(&1, date, indexes))
    else
      {:error, error} when is_atom(error) -> :ok
      {:error, error} -> Logger.error("[##{file_index} #{file_name}:#{line_index}] #{error}")
    end
  end

  defp extract_data(line) do
    [
      _id,
      notification_datetime,
      symptoms_datetime,
      _birth_date,
      _symptoms,
      is_health_professional,
      _cbo,
      _conditions,
      _test_state,
      _test_date,
      _test_type,
      test_result,
      _origin_country,
      gender,
      _residence_state,
      _residence_state_id,
      _residence_city,
      residence_city_id,
      _origin,
      _cnes,
      _notification_state,
      _notification_state_id,
      _notification_city,
      notification_city_id,
      _removed,
      _validated,
      age,
      _ending_date,
      _case_evolution,
      final_classification
    ] = line

    {
      :ok,
      {
        {symptoms_datetime, notification_datetime},
        {residence_city_id, notification_city_id},
        {test_result, final_classification},
        {gender, age},
        is_health_professional
      }
    }
  rescue
    error -> {:error, format_error(error, __STACKTRACE__)}
  end

  defp identify_date({symptoms_datetime, notification_datetime}, today) do
    case parse_datetime(symptoms_datetime, today) do
      {:ok, date} -> {:ok, date}
      _error -> parse_datetime(notification_datetime, today)
    end
  end

  defp parse_datetime(datetime, today) do
    case NaiveDateTime.from_iso8601(datetime) do
      {:ok, datetime} ->
        date = NaiveDateTime.to_date(datetime)

        if Date.compare(date, @first_case_date) in [:eq, :gt] and Date.compare(date, today) in [:eq, :lt] do
          {:ok, date}
        else
          {:error, :invalid_datetime}
        end

      _error ->
        {:error, :invalid_datetime}
    end
  end

  defp identify_locations_ids_list({residence_city_id, notification_city_id}) do
    if residence_city_id == notification_city_id do
      case identify_locations_ids(residence_city_id) do
        nil -> {:error, :invalid_city_ids}
        locations -> {:ok, [{@residence, locations}, {@notification, locations}]}
      end
    else
      case {identify_locations_ids(residence_city_id), identify_locations_ids(notification_city_id)} do
        {nil, nil} -> {:error, :invalid_city_ids}
        {locations_ids, nil} -> {:ok, [{@residence, locations_ids}]}
        {nil, locations_ids} -> {:ok, [{@notification, locations_ids}]}
        {[id | _], [id | _] = locations_ids} -> {:ok, [{@residence, locations_ids}, {@notification, locations_ids}]}
        {rls, nls} -> {:ok, [{@residence, rls}, {@notification, nls}]}
      end
    end
  end

  defp identify_locations_ids(city_id) do
    if city_id != "" do
      case :ets.lookup(@ets_cities, String.to_integer(city_id)) do
        [{city_id, locations_ids}] -> [city_id | locations_ids]
        _records -> nil
      end
    else
      nil
    end
  rescue
    _error -> nil
  end

  defp identify_indexes(classification, gender_age, is_health_professional) do
    case identify_classification_index(classification) do
      @confirmed_index ->
        [@confirmed_index]
        |> maybe_add_gender_age_group_index(gender_age)
        |> maybe_add_health_professional_index(is_health_professional)
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
      |> String.upcase()
      |> case do
        "P" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp identify_final_classification_index(final_classification) do
    if final_classification != "" do
      final_classification
      |> String.first()
      |> String.upcase()
      |> case do
        "C" -> @confirmed_index
        _char -> @discarded_index
      end
    else
      @discarded_index
    end
  end

  defp maybe_add_health_professional_index(indexes, is_health_professional) do
    if is_health_professional != "" do
      is_health_professional
      |> String.first()
      |> String.upcase()
      |> case do
        "S" -> [@health_professional_index | indexes]
        _char -> indexes
      end
    else
      indexes
    end
  end

  defp update_buckets({registry_context, locations_ids}, date, indexes) do
    locations = [76 | locations_ids]
    indexes_additions = Enum.map(indexes, &{&1, 1})

    for location_id <- locations, bucket <- buckets_from_date(date) do
      update_bucket(registry_context, bucket, location_id, indexes_additions)
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

  defp update_bucket(registry_context, bucket, location_id, indexes_additions) do
    {bucket_name, key} =
      case bucket do
        {bucket_name, date} -> {bucket_name, {registry_context, location_id, date}}
        bucket_name -> {bucket_name, {registry_context, location_id}}
      end

    :ets.update_counter(
      bucket_name,
      key,
      indexes_additions,
      {key, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0}
    )
  end

  @spec save :: :ok
  def save do
    :ok
  end

  @spec setup :: :ok
  def setup do
    :ets.delete_all_objects(@ets_pandemic_buckets)
    :ets.delete_all_objects(@ets_monthly_buckets)
    :ets.delete_all_objects(@ets_weekly_buckets)
    :ets.delete_all_objects(@ets_daily_buckets)

    :ok
  end

  @spec shutdown :: :ok
  def shutdown do
    :ets.delete(@ets_cities)

    :ets.delete(@ets_pandemic_buckets)
    :ets.delete(@ets_monthly_buckets)
    :ets.delete(@ets_weekly_buckets)
    :ets.delete(@ets_daily_buckets)

    :ok
  end

  @spec write(String.t()) :: :ok
  def write(dir) do
    File.rm_rf!(dir)
    File.mkdir_p!(dir)

    write_bucket(@ets_pandemic_buckets, &pandemic_line/1, Path.join(dir, "pandemic_flu_syndrome_cases.csv"))
    write_bucket(@ets_monthly_buckets, &monthly_line/1, Path.join(dir, "monthly_flu_syndrome_cases.csv"))
    write_bucket(@ets_weekly_buckets, &weekly_line/1, Path.join(dir, "weekly_flu_syndrome_cases.csv"))
    write_bucket(@ets_daily_buckets, &daily_line/1, Path.join(dir, "daily_flu_syndrome_cases.csv"))

    dir
    |> File.ls!()
    |> Enum.each(&sort_and_chunk_file(&1, dir))
  end

  defp write_bucket(bucket_name, line_function, file_path) do
    Logger.info("Writing #{bucket_name}")

    records = :ets.tab2list(bucket_name)
    :ets.delete_all_objects(bucket_name)

    records
    |> Enum.map(&line_function.(&1))
    |> Enum.join("\n")
    |> write_to_file(file_path)
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

  @split_command Application.compile_env!(:health_board, :split_command)

  defp sort_and_chunk_file(file_name, output_dir) do
    name = Path.basename(file_name, ".csv")

    Logger.info("Sorting and chunking #{name}")

    file_path = Path.join(output_dir, file_name)

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])

    dir = Path.join(output_dir, Path.basename(file_name, ".csv"))

    File.mkdir_p!(dir)

    chunk_file_path = Path.join(dir, "#{name}_")

    {_result, 0} =
      System.cmd(
        @split_command,
        ~w[-d -a 4 -l 100000 --additional-suffix=.csv #{file_path} #{chunk_file_path}]
      )

    File.rm!(file_path)
  end
end
