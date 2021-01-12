defmodule HealthBoard.Updaters.CovidReportsUpdater.Consolidator do
  require Logger
  alias HealthBoard.Contexts.Geo.Locations

  @ets_cities :situation_report_cities

  @ets_daily_buckets :situation_report_consolidation_daily
  @ets_weekly_buckets :situation_report_consolidation_weekly
  @ets_monthly_buckets :situation_report_consolidation_monthly
  @ets_yearly_buckets :situation_report_consolidation_yearly
  @ets_pandemic_buckets :situation_report_consolidation_pandemic

  @brazil_id 76

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
    :ets.new(@ets_yearly_buckets, [:set, :public, :named_table])
    :ets.new(@ets_pandemic_buckets, [:set, :public, :named_table])

    :ok
  end

  defp locations_ids(%{id: city_id, parents: [%{parent_id: health_region_id}]}) do
    state_id = Locations.state_id(city_id, :city)
    region_id = Locations.region_id(state_id, :state)

    {
      Integer.to_string(div(city_id, 10)),
      [
        city_id,
        health_region_id,
        state_id,
        region_id
      ]
    }
  end

  @spec parse({list(String.t()), integer}) :: :ok
  def parse({line, line_index}) do
    [_region, _state, _city, _state_id, city_id | line] = line

    if city_id != "" do
      with [{_city_id, locations_ids}] <- :ets.lookup(@ets_cities, city_id) do
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

        Enum.each([@brazil_id | locations_ids], &update_buckets(&1, date, cases, deaths))
      end
    end

    :ok
  rescue
    error -> Logger.error("[#{line_index}] #{Exception.message(error)}\n#{Exception.format_stacktrace(__STACKTRACE__)}")
  end

  defp update_buckets(location_id, %{year: year, month: month, day: day}, cases, deaths) do
    update_bucket(@ets_daily_buckets, {location_id, {year, month, day}}, cases, deaths)
    update_bucket(@ets_weekly_buckets, {location_id, :calendar.iso_week_number({year, month, day})}, cases, deaths)
    update_bucket(@ets_monthly_buckets, {location_id, {year, month}}, cases, deaths)
    update_bucket(@ets_yearly_buckets, {location_id, year}, cases, deaths)
    update_bucket(@ets_pandemic_buckets, location_id, cases, deaths)
  end

  defp update_bucket(bucket_name, key, cases, deaths) do
    :ets.update_counter(bucket_name, key, [{2, cases}, {3, deaths}], {key, 0, 0})
  end

  @spec save :: :ok
  def save do
    :ok
  end

  @spec setup :: :ok
  def setup do
    :ets.delete_all_objects(@ets_pandemic_buckets)
    :ets.delete_all_objects(@ets_yearly_buckets)
    :ets.delete_all_objects(@ets_monthly_buckets)
    :ets.delete_all_objects(@ets_weekly_buckets)
    :ets.delete_all_objects(@ets_daily_buckets)

    :ok
  end

  @spec shutdown :: :ok
  def shutdown do
    :ets.delete(@ets_cities)

    :ets.delete(@ets_pandemic_buckets)
    :ets.delete(@ets_yearly_buckets)
    :ets.delete(@ets_monthly_buckets)
    :ets.delete(@ets_weekly_buckets)
    :ets.delete(@ets_daily_buckets)

    :ok
  end

  @spec write(String.t()) :: :ok
  def write(dir) do
    File.rm_rf!(dir)
    File.mkdir_p!(dir)

    write_bucket(@ets_pandemic_buckets, &pandemic_line/1, Path.join(dir, "pandemic_covid_reports.csv"))
    write_bucket(@ets_yearly_buckets, &yearly_line/1, Path.join(dir, "yearly_covid_reports.csv"))
    write_bucket(@ets_monthly_buckets, &monthly_line/1, Path.join(dir, "monthly_covid_reports.csv"))
    write_bucket(@ets_weekly_buckets, &weekly_line/1, Path.join(dir, "weekly_covid_reports.csv"))
    write_bucket(@ets_daily_buckets, &daily_line/1, Path.join(dir, "daily_covid_reports.csv"))

    dir
    |> File.ls!()
    |> Enum.each(&sort_and_chunk_file(&1, dir))
  end

  defp write_bucket(bucket_name, line_function, file_path) do
    Logger.info("Writing #{bucket_name}")

    records = :ets.tab2list(bucket_name)
    :ets.delete_all_objects(bucket_name)

    records
    |> Enum.map(&Enum.join(line_function.(&1), ","))
    |> Enum.join("\n")
    |> write_to_file(file_path)
  end

  defp write_to_file(content, file_path) do
    File.write!(file_path, content)
  end

  defp pandemic_line({location_id, cases, deaths}), do: [location_id, cases, deaths]
  defp yearly_line({{location_id, year}, cases, deaths}), do: [location_id, year, cases, deaths]
  defp monthly_line({{location_id, {year, month}}, cases, deaths}), do: [location_id, year, month, cases, deaths]
  defp weekly_line({{location_id, {year, week}}, cases, deaths}), do: [location_id, year, week, cases, deaths]
  defp daily_line({{location_id, date}, cases, deaths}), do: [location_id, Date.from_erl!(date), cases, deaths]

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
