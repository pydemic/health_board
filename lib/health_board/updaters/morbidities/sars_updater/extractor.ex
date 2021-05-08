defmodule HealthBoard.Updaters.SARSUpdater.Extractor do
  require Logger

  @filename "srag"

  @spec extract(String.t(), String.t()) :: :ok
  def extract(input_path, output_path) do
    output_file_path = Path.join(output_path, "#{@filename}.csv")

    File.rm_rf!(output_file_path)
    File.mkdir_p!(output_path)

    input_path
    |> File.ls!()
    |> Enum.with_index(0)
    |> Enum.each(&join_file(elem(&1, 1), Path.join(input_path, elem(&1, 0)), output_file_path))

    finish_extraction(output_file_path)

    :ok
  end

  defp join_file(index, input_file_path, output_file_path) do
    if index != 0 do
      join_file_and_remove_header(input_file_path, output_file_path)
    else
      {_result, 0} =
        System.cmd("sh", [
          "-c",
          "cat " <> input_file_path <> " >> " <> output_file_path
        ])
    end
  end

  defp join_file_and_remove_header(input_file_path, output_file_path) do
    {_result, 0} =
      System.cmd("sh", [
        "-c",
        "sed '1d' " <> input_file_path <> " >> " <> output_file_path
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
