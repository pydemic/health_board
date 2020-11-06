defmodule HealthBoard.Scripts.DATASUS.SINASC.YearlyConsolidator do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")

  @groups ["source", "resident"]
  @locations ["cities", "health_regions", "states", "regions", "countries"]

  @buckets_dirs ["source_health_institutions_births"] ++
                  for(group <- @groups, location <- @locations, do: "#{group}_#{location}_births")

  @results_dir Path.join(@dir, "results/demographic")

  @spec run :: :ok
  def run do
    Enum.each(@buckets_dirs, &consolidate_buckets/1)
  end

  defp consolidate_buckets(buckets_dir) do
    results_dir = Path.join(@results_dir, "yearly_" <> buckets_dir)
    buckets_dir = Path.join(@sources_dir, buckets_dir)

    File.mkdir_p!(results_dir)

    buckets_dir
    |> File.ls!()
    |> inform_files()
    |> Enum.with_index(1)
    |> Task.async_stream(&consolidate(&1, buckets_dir, results_dir), timeout: :infinity, max_concurrency: 4)
    |> Stream.run()
  end

  defp inform_files(files) do
    Logger.info("#{Enum.count(files)} files identified")
    files
  end

  defp consolidate({file_name, file_index}, buckets_dir, results_dir) do
    Logger.info("[#{file_index}] Extracting #{file_name}")

    [location_id, _csv] = String.split(file_name, ".")

    buckets_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(%{}, &do_consolidate/2)
    |> append_to_csv(Path.join(results_dir, "#{location_id}.csv"))
  end

  defp do_consolidate(data, consolidations) do
    [_date, year, _week | year_data] = data

    year = String.to_integer(year)

    year_data = Enum.map(year_data, &String.to_integer/1)

    Map.update(consolidations, year, year_data, &add_metrics(&1, year_data))
  end

  defp add_metrics(metrics1, metrics2) do
    metrics1
    |> Enum.zip(metrics2)
    |> Enum.map(&(elem(&1, 0) + elem(&1, 1)))
  end

  defp append_to_csv(location_data, location_file_path) do
    location_file = File.open!(location_file_path, [:append])

    location_data
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
    |> Enum.each(&write_line(&1, location_file))

    File.close(location_file)
  end

  defp write_line({year, year_data}, location_file) do
    IO.write(location_file, Enum.join([year] ++ year_data, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SINASC.YearlyConsolidator.run()
