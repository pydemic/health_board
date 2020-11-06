defmodule HealthBoard.Scripts.DATASUS.SINASC.HeathInstitutionsBucket do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")

  @base_data_dir Path.join(@sources_dir, "base_data")
  @preliminar_dir Path.join(@sources_dir, "health_institutions_data")

  @spec run :: :ok
  def run do
    @base_data_dir
    |> File.ls!()
    |> inform_files()
    |> Enum.with_index(1)
    |> Enum.each(&consolidate/1)
  end

  defp inform_files(files) do
    Logger.info("#{Enum.count(files)} files identified")
    files
  end

  defp consolidate({base_data_file_name, file_index}) do
    Logger.info("[#{file_index}] Extracting #{base_data_file_name}")

    @base_data_dir
    |> Path.join(base_data_file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream()
    |> Enum.reduce(%{}, &do_consolidate/2)
    |> append_to_csvs()
  end

  defp do_consolidate(data, consolidations) do
    [
      _source_health_institution_id,
      health_institution_id,
      _resident_health_institution_id,
      date,
      year,
      week | metric_data
    ] = data

    date = Date.from_iso8601!(date)

    year = String.to_integer(year)
    week = String.to_integer(week)

    metric_data = Enum.map(metric_data, &parse_metric/1)

    date_data = %{
      non_metric: [year, week],
      metric: metric_data
    }

    consolidate_group(consolidations, health_institution_id, date, date_data)
  end

  defp consolidate_group(consolidations, health_institution_id, date, date_data) do
    if health_institution_id != "" do
      health_institution_id = String.to_integer(health_institution_id)

      Map.update(
        consolidations,
        health_institution_id,
        %{date => date_data},
        &merge_health_institution_data(&1, date, date_data)
      )
    else
      consolidations
    end
  end

  defp parse_metric(metric) do
    if metric != "" do
      String.to_integer(metric)
    else
      0
    end
  end

  defp merge_health_institution_data(health_institution_data, date, %{metric: metric_data} = date_data) do
    Map.update(health_institution_data, date, date_data, &merge_date_data(&1, metric_data))
  end

  defp merge_date_data(date_data, metric_data) do
    Map.update!(date_data, :metric, &add_metrics(&1, metric_data))
  end

  defp add_metrics(metrics1, metrics2) do
    metrics1
    |> Enum.zip(metrics2)
    |> Enum.map(&(elem(&1, 0) + elem(&1, 1)))
  end

  defp append_to_csvs(consolidations) do
    Enum.each(consolidations, &append_to_health_institution_csv(&1, @preliminar_dir))
  end

  defp append_to_health_institution_csv({health_institution_id, health_institution_data}, preliminar_dir) do
    preliminar_file = File.open!(Path.join(preliminar_dir, "#{health_institution_id}.csv"), [:append])

    Enum.each(health_institution_data, &write_line(&1, preliminar_file))

    File.close(preliminar_file)
  end

  defp write_line({date, %{non_metric: non_metric_data, metric: metric_data}}, preliminar_file) do
    IO.write(preliminar_file, Enum.join([date] ++ non_metric_data ++ metric_data, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SINASC.HeathInstitutionsBucket.run()
