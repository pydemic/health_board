defmodule HealthBoard.Updaters.FluSyndromeUpdater.Extractor do
  require Logger

  @filename "sg"
  @headers [
    "municipioIBGE",
    "dataInicioSintomas",
    "dataNascimento",
    "idade",
    "sexo",
    "profissionalSaude",
    "resultadoTeste",
    "evolucaoCaso",
    "dataEncerramento",
    "classificacaoFinal",
    "dataNotificacao"
  ]

  @spec extract(String.t(), String.t()) :: :ok
  def extract(input_path, output_path) do
    output_file_path = Path.join(output_path, "#{@filename}.csv")

    File.rm_rf!(output_file_path)
    File.mkdir_p!(output_path)

    output_file = File.open!(output_file_path, [:write, :append, :utf8])

    IO.binwrite(output_file, NimbleCSV.RFC4180.dump_to_iodata([@headers]))

    File.close(output_file)

    input_path
    |> File.ls!()
    |> Enum.each(&extract_file(Path.join(input_path, &1), output_file_path))

    finish_extraction(output_file_path)

    :ok
  end

  defp extract_file(input_file_path, output_file_path) do
    filename = Path.basename(input_file_path)

    temporary_path = "/tmp/flu_syndrome_extractor_temporary"

    temporary_file_path = Path.join(temporary_path, filename)

    File.rm_rf!(temporary_path)
    File.mkdir_p!(temporary_path)

    fix_enconding_file(input_file_path, temporary_file_path)

    remove_header(temporary_file_path)

    extract_data(temporary_file_path, output_file_path)

    File.rm_rf!(temporary_path)
  end

  defp fix_enconding_file(input_file_path, temporary_file_path) do
    {_result, 0} =
      System.cmd("sh", ["-c", "iconv -f windows-1252 -t utf-8 " <> input_file_path <> " > " <> temporary_file_path])
  end

  defp remove_header(temporary_file_path) do
    {_result, 0} =
      System.cmd("sh", [
        "-c",
        "csvtool drop 1 " <> temporary_file_path <> " > temp.csv && mv temp.csv " <> temporary_file_path
      ])
  end

  defp extract_data(temporary_file_path, output_file_path) do
    {line_length, 0} =
      System.cmd("sh", [
        "-c",
        "head -n 1 " <> temporary_file_path <> " | awk -F ';' '{print NF}'"
      ])

    case line_length do
      "29\n" ->
        slice_file(
          temporary_file_path,
          output_file_path,
          "'%(18),%(3),%(4),%(26),%(14),%(6),%(12),%(28),%(27),%(29),%(2)\n'"
        )

      "30\n" ->
        slice_file(
          temporary_file_path,
          output_file_path,
          "'%(18),%(3),%(4),%(26),%(14),%(6),%(12),%(28),%(27),%(29),%(2)\n'"
        )
    end
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
