defmodule HealthBoard.Scripts.DATASUS.SINASC.SumDatesData do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/births")
  @groups ["resident", "source"]

  @results_dir Path.join(@dir, "results/demographic/births")

  @spec run :: :ok
  def run do
    File.rm_rf!(@results_dir)
    Enum.each(@groups, &sum_from_group/1)
  end

  defp sum_from_group(group) do
    @sources_dir
    |> Path.join(group)
    |> File.ls!()
    |> inform_files_from_group(group)
    |> Enum.each(&sum_from_file(&1, group))
  end

  defp inform_files_from_group(files, group) do
    Logger.info("#{Enum.count(files)} files identified from #{group}")
    files
  end

  defp sum_from_file(group_dir, group) do
    File.mkdir_p!(Path.join(@results_dir, group))

    @sources_dir
    |> Path.join(group)
    |> Path.join(group_dir)
    |> File.ls!()
    |> inform_files_from_group_dir(group_dir)
    |> Stream.with_index(1)
    |> Task.async_stream(&sum_dates_data(&1, group_dir, group), timeout: :infinity, max_concurrency: 4)
    |> Stream.run()
  end

  defp inform_files_from_group_dir(files, group_dir) do
    Logger.info("#{Enum.count(files)} .csv files identified from #{group_dir}")
    files
  end

  defp sum_dates_data({csv_file_name, file_index}, group_dir, group) do
    Logger.info("[#{file_index}] Extracting #{csv_file_name}")

    result_file_path =
      @results_dir
      |> Path.join(group)
      |> Path.join(group_dir)
      |> Path.join(csv_file_name)

    @sources_dir
    |> Path.join(group)
    |> Path.join(group_dir)
    |> Path.join(csv_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce(%{}, &do_sum_dates_data/2)
    |> write_to_csv(result_file_path)
  end

  defp do_sum_dates_data(data, consolidations) do
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

  defp write_to_csv(consolidations, file_path) do
    File.mkdir_p!(Path.dirname(file_path))
    file = File.open!(file_path, [:write])

    consolidations
    |> Enum.sort(&(Date.compare(elem(&1, 0), elem(&2, 0)) == :gt))
    |> Enum.each(&write_line(&1, file))

    File.close(file)
  end

  defp write_line({date, %{non_metric: non_metric_data, metric: metric_data}}, file) do
    IO.write(file, Enum.join([date] ++ non_metric_data ++ metric_data, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SINASC.SumDatesData.run()
