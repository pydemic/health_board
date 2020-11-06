defmodule HealthBoard.Scripts.DATASUS.SINASC.CitiesBucket do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "sources/sinasc")

  @base_data_dir Path.join(@sources_dir, "base_data")
  @resident_preliminar_dir Path.join(@sources_dir, "cities_data/resident_cities_data")
  @source_preliminar_dir Path.join(@sources_dir, "cities_data/source_cities_data")

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
    |> Enum.reduce({%{}, %{}}, &do_consolidate/2)
    |> append_to_source_csvs()
    |> append_to_resident_csvs()
  end

  defp do_consolidate(data, {source_consolidations, resident_consolidations}) do
    [source_city_id, _health_institution_id, resident_city_id, date, year, week | metric_data] = data

    date = Date.from_iso8601!(date)

    year = String.to_integer(year)
    week = String.to_integer(week)

    metric_data = Enum.map(metric_data, &parse_metric/1)

    date_data = %{
      non_metric: [year, week],
      metric: metric_data
    }

    source_consolidations = consolidate_group(source_consolidations, source_city_id, date, date_data)
    resident_consolidations = consolidate_group(resident_consolidations, resident_city_id, date, date_data)

    {source_consolidations, resident_consolidations}
  end

  defp consolidate_group(consolidations, city_id, date, date_data) do
    if city_id != "" do
      city_id = String.to_integer(city_id)

      Map.update(
        consolidations,
        city_id,
        %{date => date_data},
        &merge_city_data(&1, date, date_data)
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

  defp merge_city_data(city_data, date, %{metric: metric_data} = date_data) do
    Map.update(city_data, date, date_data, &merge_date_data(&1, metric_data))
  end

  defp merge_date_data(date_data, metric_data) do
    Map.update!(date_data, :metric, &add_metrics(&1, metric_data))
  end

  defp add_metrics(metrics1, metrics2) do
    metrics1
    |> Enum.zip(metrics2)
    |> Enum.map(&(elem(&1, 0) + elem(&1, 1)))
  end

  defp append_to_source_csvs({source_consolidations, resident_consolidations}) do
    Enum.each(source_consolidations, &append_to_city_csv(&1, @source_preliminar_dir))
    resident_consolidations
  end

  defp append_to_city_csv({city_id, city_data}, preliminar_dir) do
    preliminar_file = File.open!(Path.join(preliminar_dir, "#{city_id}.csv"), [:append])

    Enum.each(city_data, &write_line(&1, city_id, preliminar_file))

    File.close(preliminar_file)
  end

  defp write_line({date, %{non_metric: non_metric_data, metric: metric_data}}, city_id, preliminar_file) do
    IO.write(preliminar_file, Enum.join([city_id, date] ++ non_metric_data ++ metric_data, ",") <> "\n")
  end

  defp append_to_resident_csvs(resident_consolidations) do
    Enum.each(resident_consolidations, &append_to_city_csv(&1, @resident_preliminar_dir))
  end
end

HealthBoard.Scripts.DATASUS.SINASC.CitiesBucket.run()
