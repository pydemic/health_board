defmodule HealthBoard.Updaters.FluSyndromeUpdater.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Consolidations.ConsolidationsGroups
  alias HealthBoard.Contexts.Geo.Locations

  @first_case_date Date.from_erl!({2020, 02, 26})

  @confirmed_index 2
  @discarded_index 3
  @health_professionals_index 4
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

  @ets_cities :health_board_updaters_flu_syndrome_cities

  @ets_consolidations_groups :health_board_updaters_flu_syndrome__consolidations_groups
  @ets_daily_locations_buckets :health_board_flu_syndrome_updater__daily_consolidations
  @ets_weekly_locations_buckets :health_board_flu_syndrome_updater__weekly_consolidations
  @ets_monthly_locations_buckets :health_board_flu_syndrome_updater__monthly_consolidations
  @ets_yearly_locations_buckets :health_board_flu_syndrome_updater__yearly_consolidations
  @ets_locations_buckets :health_board_flu_syndrome_updater__locations_consolidations
  @ets_locations_dates_buckets :health_board_flu_syndrome_updater__locations_dates

  @confirmed_cases_group_name "morbidities_flu_syndrome_residence_confirmed_cases"
  @discarded_cases_group_name "morbidities_flu_syndrome_residence_discarded_cases"
  @health_professionals_cases_group_name "morbidities_flu_syndrome_residence_health_professionals_cases"
  @cases_per_age_gender_group_name "morbidities_flu_syndrome_residence_cases_per_age_gender"

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

  defp parse({line, line_index, filename, today}) do
    with {:ok, {datetimes, city_id, class, result, is_health_professional, age, gender}} <- extract_line_data(line),
         {:ok, date} <- fetch_date(datetimes, today),
         {:ok, locations_ids} <- fetch_locations_ids(city_id) do
      counters =
        if String.first(class) in ["C", "c"] or String.first(result) in ["P", "p"] do
          [{@confirmed_index, 1}]
          |> maybe_add_health_professionals_counter(is_health_professional)
          |> maybe_add_age_gender_counter(age, gender)
        else
          [{@discarded_index, 1}]
        end

      Enum.each(locations_ids, &update_buckets(&1, date, counters))
    end
  rescue
    error ->
      Logger.error("""
      [#{filename}:#{line_index}] #{Exception.message(error)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      #{inspect(line, pretty: true, limit: :infinity, charlists: :as_lists, binaries: :as_strings)}
      """)
  end

  defp extract_line_data(line) do
    line_length = length(line)

    case line_length do
      29 ->
        [
          _id,
          notification_datetime,
          symptoms_datetime,
          _birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _test_status,
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
          _notification_state,
          _notification_state_id,
          _notification_city,
          _notification_city_id,
          _removed,
          _validated,
          age,
          _final_date,
          _case_evolution,
          final_classification
        ] = line

        {:ok,
         {
           [notification_datetime, symptoms_datetime],
           residence_city_id,
           final_classification,
           test_result,
           is_health_professional,
           age,
           gender
         }}

      30 ->
        [
          _id,
          notification_datetime,
          symptoms_datetime,
          _birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _test_status,
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
          _notification_city_id,
          _removed,
          _validated,
          age,
          _final_date,
          _case_evolution,
          final_classification
        ] = line

        {:ok,
         {[notification_datetime, symptoms_datetime], residence_city_id, final_classification, test_result,
          is_health_professional, age, gender}}

      31 ->
        [
          _id,
          notification_datetime,
          symptoms_datetime,
          _birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _conditions_2,
          _conditions_3,
          _test_status,
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
          _notification_state,
          _notification_state_id,
          _notification_city,
          _notification_city_id,
          _removed,
          _validated,
          age,
          _final_date,
          _case_evolution,
          final_classification
        ] = line

        {:ok,
         {[notification_datetime, symptoms_datetime], residence_city_id, final_classification, test_result,
          is_health_professional, age, gender}}

      _line_length ->
        {:error, :invalid_line}
    end
  end

  defp fetch_date(datetimes, today) do
    case Enum.find_value(datetimes, &datetime_to_date(&1, today)) do
      nil -> {:error, :invalid_datetimes}
      date -> {:ok, date}
    end
  end

  defp datetime_to_date(datetime, today) do
    with {:ok, datetime} <- NaiveDateTime.from_iso8601(datetime),
         date <- NaiveDateTime.to_date(datetime),
         true <- Date.compare(@first_case_date, date) in [:lt, :eq],
         true <- Date.compare(date, today) in [:lt, :eq] do
      date
    else
      _result -> nil
    end
  end

  defp fetch_locations_ids(city_id) do
    with true <- city_id != "",
         [{_city_id, locations_ids}] <- :ets.lookup(@ets_cities, city_id) do
      {:ok, locations_ids}
    else
      _result -> {:error, :invalid_city_id}
    end
  end

  defp maybe_add_health_professionals_counter(counters, is_health_professional) do
    if String.first(is_health_professional) in ["S", "s"] do
      [{@health_professionals_index, 1} | counters]
    else
      counters
    end
  end

  defp maybe_add_age_gender_counter(counters, age, gender) do
    case String.first(gender) do
      "F" -> maybe_add_age_gender_counter_with_gender_index(counters, age, @female_index)
      "M" -> maybe_add_age_gender_counter_with_gender_index(counters, age, @male_index)
      _result -> counters
    end
  end

  defp maybe_add_age_gender_counter_with_gender_index(counters, age, gender_index) do
    if age != "" do
      age = String.to_integer(age)

      cond do
        age < 0 -> nil
        age <= 4 -> [{@age_0_4_offset + gender_index, 1} | counters]
        age <= 9 -> [{@age_5_9_offset + gender_index, 1} | counters]
        age <= 14 -> [{@age_10_14_offset + gender_index, 1} | counters]
        age <= 19 -> [{@age_15_19_offset + gender_index, 1} | counters]
        age <= 24 -> [{@age_20_24_offset + gender_index, 1} | counters]
        age <= 29 -> [{@age_25_29_offset + gender_index, 1} | counters]
        age <= 34 -> [{@age_30_34_offset + gender_index, 1} | counters]
        age <= 39 -> [{@age_35_39_offset + gender_index, 1} | counters]
        age <= 44 -> [{@age_40_44_offset + gender_index, 1} | counters]
        age <= 49 -> [{@age_45_49_offset + gender_index, 1} | counters]
        age <= 54 -> [{@age_50_54_offset + gender_index, 1} | counters]
        age <= 59 -> [{@age_55_59_offset + gender_index, 1} | counters]
        age <= 64 -> [{@age_60_64_offset + gender_index, 1} | counters]
        age <= 69 -> [{@age_65_69_offset + gender_index, 1} | counters]
        age <= 74 -> [{@age_70_74_offset + gender_index, 1} | counters]
        age <= 79 -> [{@age_75_79_offset + gender_index, 1} | counters]
        true -> [{@age_80_or_more_offset + gender_index, 1} | counters]
      end
    else
      counters
    end
  rescue
    _error -> counters
  end

  defp update_buckets(location_id, %{year: year, month: month, day: day}, counters) do
    update_bucket(@ets_daily_locations_buckets, {location_id, {year, month, day}}, counters)

    update_bucket(
      @ets_weekly_locations_buckets,
      {location_id, :calendar.iso_week_number({year, month, day})},
      counters
    )

    update_bucket(@ets_monthly_locations_buckets, {location_id, {year, month}}, counters)
    update_bucket(@ets_yearly_locations_buckets, {location_id, year}, counters)
    update_bucket(@ets_locations_buckets, location_id, counters)
  end

  defp update_bucket(bucket_name, key, counters) do
    :ets.update_counter(
      bucket_name,
      key,
      counters,
      {key, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
       0}
    )
  end

  defp write(dir, split_command) do
    confirmed_cases_id = :ets.lookup_element(@ets_consolidations_groups, :confirmed_cases, 2)
    discarded_cases_id = :ets.lookup_element(@ets_consolidations_groups, :discarded_cases, 2)
    health_professionals_cases_id = :ets.lookup_element(@ets_consolidations_groups, :health_professionals_cases, 2)
    cases_per_age_gender_id = :ets.lookup_element(@ets_consolidations_groups, :cases_per_age_gender, 2)
    groups_ids = {confirmed_cases_id, discarded_cases_id, health_professionals_cases_id, cases_per_age_gender_id}

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

    {confirmed_cases_lines, discarded_cases_lines, health_professionals_cases_lines, cases_per_age_gender_lines} =
      Enum.reduce(records, {[], [], [], []}, &to_lines(consolidation_type, &1, &2, groups_ids))

    {confirmed_cases_id, discarded_cases_id, health_professionals_cases_id, cases_per_age_gender_id} = groups_ids

    [
      write_lines(confirmed_cases_lines, dir, consolidation_type, confirmed_cases_id, @confirmed_cases_group_name),
      write_lines(discarded_cases_lines, dir, consolidation_type, discarded_cases_id, @discarded_cases_group_name),
      write_lines(
        health_professionals_cases_lines,
        dir,
        consolidation_type,
        health_professionals_cases_id,
        @health_professionals_cases_group_name
      ),
      write_lines(
        cases_per_age_gender_lines,
        dir,
        consolidation_type,
        cases_per_age_gender_id,
        @cases_per_age_gender_group_name
      )
    ]
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
    File.write!(file_path, content, [:utf8])
  end

  defp to_lines(consolidation_type, record, lines, groups_ids) do
    {
      record_key,
      confirmed_cases,
      discarded_cases,
      health_professionals_cases,
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
    } = record

    {confirmed_cases_lines, discarded_cases_lines, health_professionals_cases_lines, cases_per_age_gender_lines} = lines
    {confirmed_cases_id, discarded_cases_id, health_professionals_cases_id, cases_per_age_gender_id} = groups_ids

    if consolidation_type == :locations do
      {
        if confirmed_cases > 0 do
          [{_key, from, to}] = :ets.lookup(@ets_locations_dates_buckets, {record_key, @confirmed_index})

          [
            Enum.join(
              [
                confirmed_cases_id,
                record_key,
                confirmed_cases,
                nil,
                from,
                to
              ],
              ","
            )
            | confirmed_cases_lines
          ]
        else
          confirmed_cases_lines
        end,
        if discarded_cases > 0 do
          [{_key, from, to}] = :ets.lookup(@ets_locations_dates_buckets, {record_key, @discarded_index})

          [
            Enum.join(
              [
                discarded_cases_id,
                record_key,
                discarded_cases,
                nil,
                from,
                to
              ],
              ","
            )
            | discarded_cases_lines
          ]
        else
          discarded_cases_lines
        end,
        if health_professionals_cases > 0 do
          [{_key, from, to}] = :ets.lookup(@ets_locations_dates_buckets, {record_key, @health_professionals_index})

          [
            Enum.join(
              [
                health_professionals_cases_id,
                record_key,
                health_professionals_cases,
                nil,
                from,
                to
              ],
              ","
            )
            | health_professionals_cases_lines
          ]
        else
          health_professionals_cases_lines
        end,
        if confirmed_cases > 0 do
          [{_key, from, to}] = :ets.lookup(@ets_locations_dates_buckets, {record_key, @confirmed_index})

          [
            Enum.join(
              [
                cases_per_age_gender_id,
                record_key,
                nil,
                ~s'"#{
                  Enum.join(
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
                    ],
                    ","
                  )
                }"',
                from,
                to
              ],
              ","
            )
            | cases_per_age_gender_lines
          ]
        else
          cases_per_age_gender_lines
        end
      }
    else
      key_cells =
        case {consolidation_type, record_key} do
          {:yearly_locations, {location_id, year}} -> [location_id, year]
          {:monthly_locations, {location_id, {year, month}}} -> [location_id, year, month]
          {:weekly_locations, {location_id, {year, week}}} -> [location_id, year, week]
          {:daily_locations, {location_id, date}} -> [location_id, Date.from_erl!(date)]
        end

      {
        if confirmed_cases > 0 do
          if consolidation_type == :daily_locations do
            location_bucket_date(key_cells, @confirmed_index)
          end

          [Enum.join([confirmed_cases_id] ++ key_cells ++ [confirmed_cases, nil], ",") | confirmed_cases_lines]
        else
          confirmed_cases_lines
        end,
        if discarded_cases > 0 do
          if consolidation_type == :daily_locations do
            location_bucket_date(key_cells, @discarded_index)
          end

          [Enum.join([discarded_cases_id] ++ key_cells ++ [discarded_cases, nil], ",") | discarded_cases_lines]
        else
          discarded_cases_lines
        end,
        if health_professionals_cases > 0 do
          if consolidation_type == :daily_locations do
            location_bucket_date(key_cells, @health_professionals_index)
          end

          [
            Enum.join([health_professionals_cases_id] ++ key_cells ++ [health_professionals_cases, nil], ",")
            | health_professionals_cases_lines
          ]
        else
          health_professionals_cases_lines
        end,
        if confirmed_cases > 0 do
          [
            Enum.join(
              [cases_per_age_gender_id] ++
                key_cells ++
                [
                  nil,
                  ~s'"#{
                    Enum.join(
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
                      ],
                      ","
                    )
                  }"'
                ],
              ","
            )
            | cases_per_age_gender_lines
          ]
        else
          cases_per_age_gender_lines
        end
      }
    end
  end

  defp location_bucket_date([location_id, date], index) do
    case :ets.lookup(@ets_locations_dates_buckets, {location_id, index}) do
      [{key, from, to}] -> :ets.insert(@ets_locations_dates_buckets, {key, min_date(from, date), max_date(to, date)})
      _result -> :ets.insert(@ets_locations_dates_buckets, {{location_id, index}, date, date})
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
      {:health_professionals_cases, ConsolidationsGroups.fetch_id!(@health_professionals_cases_group_name)},
      {:cases_per_age_gender, ConsolidationsGroups.fetch_id!(@cases_per_age_gender_group_name)}
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
      Integer.to_string(city_id),
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
