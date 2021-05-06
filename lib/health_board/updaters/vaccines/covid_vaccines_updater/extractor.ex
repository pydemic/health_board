defmodule HealthBoard.Updaters.CovidVaccinesUpdater.Extractor do
  require Logger

  @filename "vacina"

  @spec extract(String.t(), String.t()) :: :ok
  def extract(input_path, output_path) do
    output_file_path = Path.join(output_path, "#{@filename}.csv")

    File.rm_rf!(output_file_path)
    File.mkdir_p!(output_path)

    input_path
    |> File.ls!()
    |> Enum.each(&extract_file(Path.join(input_path, &1), output_file_path))

    finish_extraction(output_file_path)

    :ok
  end

  defp extract_file(input_file_path, output_file_path) do
    extract_data(input_file_path, output_file_path)
  end

  defp extract_data(file_path, output_file_path) do
    slice_file(
      file_path,
      output_file_path,
      "'%(2),%(28),%(31),%(12),%(8),%(3),%(5),%(29)\n'"
    )
  end

  defp slice_file(input_file_path, output_file_path, structure) do
    {_result, 0} =
      System.cmd("sh", [
        "-c",
        "csvtool -t ';' format " <> structure <> " " <> input_file_path <> " >> " <> output_file_path
      ])
  end

  defp finish_extraction(file_path) do
    dir_path = Path.dirname(file_path)
    filename = Path.basename(file_path, ".csv") <> ".zip"
    zip_file_path = Path.join(dir_path, filename)

    File.rm_rf!(zip_file_path)

    Logger.info("Zipping file")

    {_result, 0} =
      System.cmd("sh", [
        "-c",
        "zip -q -j " <> zip_file_path <> " " <> file_path
      ])
  end
end
