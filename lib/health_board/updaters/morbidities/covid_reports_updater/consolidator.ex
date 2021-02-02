defmodule HealthBoard.Updaters.CovidReportsUpdater.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Consolidations.ConsolidationsGroups
  alias HealthBoard.Contexts.Geo.Locations

  @ets_cities :health_board_updaters_covid_reports_cities
  @ets_states :health_board_updaters_covid_reports_states

  @ets_consolidations_groups :health_board_updaters_covid_reports_consolidations_groups
  @ets_daily_locations_buckets :health_board_covid_reports_updater_daily_consolidations
  @ets_weekly_locations_buckets :health_board_covid_reports_updater_weekly_consolidations
  @ets_monthly_locations_buckets :health_board_covid_reports_updater_monthly_consolidations
  @ets_yearly_locations_buckets :health_board_covid_reports_updater_yearly_consolidations
  @ets_locations_buckets :health_board_covid_reports_updater_locations_consolidations

  @cases_group_name "morbidities_covid_reports_cases"
  @deaths_group_name "morbidities_covid_reports_deaths"

  @spec consolidate(Enumerable.t(), String.t(), String.t()) :: :ok
  def consolidate(stream, output_path, split_command) do
    Logger.info("Parsing")

    stream
    |> Stream.with_index(1)
    |> Flow.from_enumerable()
    |> Flow.map(&parse/1)
    |> Flow.run()

    Logger.info("Finished parsing. Writing")

    write(output_path, split_command)

    Logger.info("Finished writing")

    :ok
  end

  defp parse({line, line_index}) do
    [_region, _state, _city, state_or_country_id, city_id | line] = line

    if state_or_country_id == "76" do
      extract_information_update_buckets(76, line)
    else
      if city_id == "" do
        with [{_state_id, locations_ids}] <- :ets.lookup(@ets_states, state_or_country_id) do
          Enum.each(locations_ids, &extract_information_update_buckets(&1, line))
        end
      else
        with [{_city_id, locations_ids}] <- :ets.lookup(@ets_cities, city_id) do
          Enum.each(locations_ids, &extract_information_update_buckets(&1, line))
        end
      end
    end

    :ok
  rescue
    error ->
      Logger.error("""
      [#{line_index}] #{Exception.message(error)}
      #{inspect(line, pretty: true, limit: :infinity)}
      #{Exception.format_stacktrace(__STACKTRACE__)}
      """)
  end

  defp extract_information_update_buckets(location_id, line) do
    [_health_region_id, _health_region, date | line] = line

    date = Date.from_iso8601!(date)

    [
      _week,
      _population,
      _total_cases,
      cases,
      _total_deaths,
      deaths | _line
    ] = line

    cases = String.to_integer(cases)
    deaths = String.to_integer(deaths)

    update_buckets(location_id, date, cases, deaths)
  end

  defp update_buckets(location_id, %{year: year, month: month, day: day}, cases, deaths) do
    update_bucket(@ets_daily_locations_buckets, {location_id, {year, month, day}}, cases, deaths)

    update_bucket(
      @ets_weekly_locations_buckets,
      {location_id, :calendar.iso_week_number({year, month, day})},
      cases,
      deaths
    )

    update_bucket(@ets_monthly_locations_buckets, {location_id, {year, month}}, cases, deaths)
    update_bucket(@ets_yearly_locations_buckets, {location_id, year}, cases, deaths)
    update_bucket(@ets_locations_buckets, location_id, cases, deaths)
  end

  defp update_bucket(bucket_name, key, cases, deaths) do
    :ets.update_counter(bucket_name, key, [{2, cases}, {3, deaths}], {key, 0, 0})
  end

  defp write(dir, split_command) do
    cases_id = :ets.lookup_element(@ets_consolidations_groups, :cases, 2)
    deaths_id = :ets.lookup_element(@ets_consolidations_groups, :deaths, 2)
    groups_ids = {cases_id, deaths_id}

    [
      write_buckets(@ets_locations_buckets, dir, :locations, groups_ids),
      write_buckets(@ets_yearly_locations_buckets, dir, :yearly_locations, groups_ids),
      write_buckets(@ets_monthly_locations_buckets, dir, :monthly_locations, groups_ids),
      write_buckets(@ets_weekly_locations_buckets, dir, :weekly_locations, groups_ids),
      write_buckets(@ets_daily_locations_buckets, dir, :daily_locations, groups_ids)
    ]
    |> Enum.each(fn files -> Enum.each(files, &sort_and_chunk_file(&1, split_command)) end)
  end

  defp write_buckets(bucket_name, dir, consolidation_type, {cases_id, deaths_id} = groups_ids) do
    Logger.info("Writing #{bucket_name}")

    records = :ets.tab2list(bucket_name)
    :ets.delete_all_objects(bucket_name)

    {cases_lines, deaths_lines} = Enum.reduce(records, {[], []}, &to_lines(consolidation_type, &1, &2, groups_ids))

    [
      write_lines(cases_lines, dir, consolidation_type, cases_id, @cases_group_name),
      write_lines(deaths_lines, dir, consolidation_type, deaths_id, @deaths_group_name)
    ]
  end

  defp write_lines(lines, dir, consolidation_type, group_id, group_name) do
    file_path = Path.join(dir, "#{consolidation_type}_consolidations/#{group_id}_#{group_name}.csv")

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

  defp to_lines(consolidation_type, {record_key, cases, deaths}, {cases_lines, deaths_lines}, {cases_id, deaths_id}) do
    key_cells =
      case {consolidation_type, record_key} do
        {:locations, location_id} -> [location_id]
        {:yearly_locations, {location_id, year}} -> [location_id, year]
        {:monthly_locations, {location_id, {year, month}}} -> [location_id, year, month]
        {:weekly_locations, {location_id, {year, week}}} -> [location_id, year, week]
        {:daily_locations, {location_id, date}} -> [location_id, Date.from_erl!(date)]
      end

    {
      [Enum.join([cases_id] ++ key_cells ++ [cases], ",") | cases_lines],
      [Enum.join([deaths_id] ++ key_cells ++ [deaths], ",") | deaths_lines]
    }
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

    [group: :cities]
    |> Locations.list_by()
    |> Locations.preload_parent(:health_regions)
    |> Enum.each(&:ets.insert_new(@ets_cities, cities_ids(&1)))

    :ets.new(@ets_states, [:set, :public, :named_table])

    [group: :states]
    |> Locations.list_by()
    |> Enum.each(&:ets.insert_new(@ets_states, states_ids(&1)))

    :ets.new(@ets_consolidations_groups, [:set, :public, :named_table])
    cases_id = ConsolidationsGroups.fetch_id!(@cases_group_name)
    deaths_id = ConsolidationsGroups.fetch_id!(@deaths_group_name)
    :ets.insert_new(@ets_consolidations_groups, [{:cases, cases_id}, {:deaths, deaths_id}])

    :ets.new(@ets_daily_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_weekly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_monthly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_yearly_locations_buckets, [:set, :public, :named_table])
    :ets.new(@ets_locations_buckets, [:set, :public, :named_table])

    :ok
  end

  defp cities_ids(%{id: city_id, parents: [%{parent_id: health_region_id}]}) do
    {
      Integer.to_string(div(city_id, 10)),
      [
        city_id,
        health_region_id
      ]
    }
  end

  defp states_ids(%{id: state_id}) do
    {
      Integer.to_string(state_id),
      [
        state_id,
        Locations.region_id(state_id, :states)
      ]
    }
  end

  @spec setup :: :ok
  def setup do
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
    :ets.delete(@ets_states)

    :ets.delete(@ets_locations_buckets)
    :ets.delete(@ets_yearly_locations_buckets)
    :ets.delete(@ets_monthly_locations_buckets)
    :ets.delete(@ets_weekly_locations_buckets)
    :ets.delete(@ets_daily_locations_buckets)

    :ok
  end
end
