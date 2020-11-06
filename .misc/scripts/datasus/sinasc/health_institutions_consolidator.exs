defmodule HealthBoard.Scripts.DATASUS.SINASC.HealthInstitutionsConsolidator do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")
  @buckets_dir Path.join(@sources_dir, "health_institutions_data")

  @results_dir Path.join(@dir, "results/demographic/health_institutions_births")

  @spec run :: :ok
  def run do
    consolidate_buckets(@buckets_dir, @results_dir)
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

  defp consolidate({heath_institution_file_name, file_index}, buckets_dir, results_dir) do
    Logger.info("[#{file_index}] Extracting #{heath_institution_file_name}")

    buckets_dir
    |> Path.join(heath_institution_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(%{}, &do_consolidate/2)
    |> append_to_csv(Path.join(results_dir, heath_institution_file_name))
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

  defp append_to_csv(heath_institution_data, heath_institution_file_path) do
    heath_institution_file = File.open!(heath_institution_file_path, [:append])

    heath_institution_data
    |> Enum.sort(&(Date.compare(elem(&1, 0), elem(&2, 0)) == :gt))
    |> Enum.each(&write_line(&1, heath_institution_file))

    File.close(heath_institution_file)
  end

  defp write_line({date, %{non_metric: non_metric_data, metric: metric_data}}, heath_institution_file) do
    IO.write(heath_institution_file, Enum.join([date] ++ non_metric_data ++ metric_data, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SINASC.HealthInstitutionsConsolidator.run()
