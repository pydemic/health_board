defmodule HealthBoard.Scripts.DATASUS.SINASC.StatesConsolidator do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")
  @source_buckets_dir Path.join(@sources_dir, "source_health_regions_births")
  @resident_buckets_dir Path.join(@sources_dir, "resident_health_regions_births")

  @results_dir Path.join(@dir, "results/demographic")
  @source_results_dir Path.join(@results_dir, "source_states_births")
  @resident_results_dir Path.join(@results_dir, "resident_states_births")

  @spec run :: :ok
  def run do
    consolidate_buckets(@source_buckets_dir, @source_results_dir)
    consolidate_buckets(@resident_buckets_dir, @resident_results_dir)
  end

  defp consolidate_buckets(buckets_dir, results_dir) do
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

  defp consolidate({health_region_file_name, file_index}, buckets_dir, results_dir) do
    Logger.info("[#{file_index}] Extracting #{health_region_file_name}")

    state_id = String.slice(health_region_file_name, 0, 2)

    buckets_dir
    |> Path.join(health_region_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(%{}, &do_consolidate/2)
    |> append_to_csv(Path.join(results_dir, "#{state_id}.csv"))
  end

  defp do_consolidate(data, consolidations) do
    [date, year, week | metric_data] = data

    date = Date.from_iso8601!(date)

    year = String.to_integer(year)
    week = String.to_integer(week)

    metric_data = Enum.map(metric_data, &String.to_integer/1)

    date_data = %{
      non_metric: [year, week],
      metric: metric_data
    }

    Map.update(consolidations, date, date_data, &merge_date_data(&1, metric_data))
  end

  defp merge_date_data(date_data, metric_data) do
    Map.update!(date_data, :metric, &add_metrics(&1, metric_data))
  end

  defp add_metrics(metrics1, metrics2) do
    metrics1
    |> Enum.zip(metrics2)
    |> Enum.map(&(elem(&1, 0) + elem(&1, 1)))
  end

  defp append_to_csv(state_data, state_file_path) do
    state_file = File.open!(state_file_path, [:append])

    state_data
    |> Enum.sort(&(Date.compare(elem(&1, 0), elem(&2, 0)) == :gt))
    |> Enum.each(&write_line(&1, state_file))

    File.close(state_file)
  end

  defp write_line({date, %{non_metric: non_metric_data, metric: metric_data}}, state_file) do
    IO.write(state_file, Enum.join([date] ++ non_metric_data ++ metric_data, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SINASC.StatesConsolidator.run()
