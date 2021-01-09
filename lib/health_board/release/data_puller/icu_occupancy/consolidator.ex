defmodule HealthBoard.Release.DataPuller.ICUOccupancy.Consolidator do
  require Logger

  alias HealthBoard.Contexts.Geo.Locations

  @ets_cities :icu_occupancy_cities

  @ets_daily_buckets :icu_occupancy_consolidation_daily

  @brazil_id 76

  @spec init :: :ok
  def init do
    :ets.new(@ets_cities, [:set, :public, :named_table])

    [context: Locations.context(:city)]
    |> Locations.list_by()
    |> Locations.preload_parent(:health_region)
    |> Enum.each(&:ets.insert_new(@ets_cities, locations_ids(&1)))

    :ets.new(@ets_daily_buckets, [:set, :public, :named_table])
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

  @spec parse({list(String.t()), integer}, Date.t() | nil) :: :ok
  def parse({line, line_index}, after_date) do
    [_region, _state, _city, _state_id, city_id | line] = line

    if city_id != "" do
      with [{_city_id, locations_ids}] <- :ets.lookup(@ets_cities, city_id) do
        [_health_region_id, _health_region, date | line] = line
        date = Date.from_iso8601!(date)

        if is_nil(after_date) or Date.compare(date, after_date) == :gt do
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
    end

    :ok
  rescue
    error -> Logger.error("[#{line_index}] #{Exception.message(error)}\n#{Exception.format_stacktrace(__STACKTRACE__)}")
  end

  defp update_buckets(location_id, %{year: year, month: month, day: day}, cases, deaths) do
    update_bucket(@ets_daily_buckets, {location_id, {year, month, day}}, cases, deaths)
  end

  defp update_bucket(bucket_name, key, cases, deaths) do
    :ets.update_counter(bucket_name, key, [{2, cases}, {3, deaths}], {key, cases, deaths})
  end

  @spec save :: :ok
  def save do
    :ok
  end

  @spec setup :: :ok
  def setup do
    :ets.delete_all_objects(@ets_daily_buckets)

    :ok
  end

  @spec shutdown :: :ok
  def shutdown do
    :ets.delete(@ets_cities)

    :ets.delete(@ets_daily_buckets)

    :ok
  end

  @spec write(String.t()) :: :ok
  def write(dir) do
    File.rm_rf!(dir)
    File.mkdir_p!(dir)

    write_bucket(@ets_daily_buckets, &daily_line/1, Path.join(dir, "daily_icu_occupancy.csv"))

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
        ~w[-d -a 4 -l 500000 --additional-suffix=.csv #{file_path} #{chunk_file_path}]
      )

    File.rm!(file_path)
  end
end
