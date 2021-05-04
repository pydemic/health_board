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
    "classificacaoFinal",
    "dataEncerramento"
  ]

  @spec extract(String.t(), String.t()) :: :ok
  def extract(input_path, output_path) do
    output_file_path = Path.join(output_path, "#{@filename}.csv")

    File.rm_rf!(output_file_path)
    File.mkdir_p!(output_path)

    output_file = File.open!(output_file_path, [:write, :append, :utf8])
    IO.binwrite(output_file, NimbleCSV.RFC4180.dump_to_iodata([@headers]))

    input_path
    |> File.ls!()
    |> Enum.each(&extract_file(Path.join(input_path, &1), output_file))

    File.close(output_file)

    finish_extraction(output_file_path)

    :ok
  end

  defp extract_file(input_file_path, output_file) do
    input_file_path
    |> File.stream!(read_ahead: 100_000, modes: [:read_ahead, {:encoding, :latin1}])
    |> NimbleCSV.Semicolon.parse_stream()
    |> Stream.map(&extract_line_data/1)
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> write(output_file)
  end

  defp extract_line_data(line) do
    line_length = length(line)

    case line_length do
      29 ->
        [
          _id,
          _notification_datetime,
          symptoms_datetime,
          birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _test_status,
          _test_date,
          _test_type,
          test_result,
          _origin_country,
          gender,
          _residence_state,
          _residence_state_id,
          _residence_city,
          residence_city_id,
          _origin,
          _notification_state,
          _notification_state_id,
          _notification_city,
          _notification_city_id,
          _removed,
          _validated,
          age,
          final_date,
          case_evolution,
          final_classification
        ] = line

        [
          residence_city_id,
          symptoms_datetime,
          birth_date,
          age,
          gender,
          is_health_professional,
          test_result,
          case_evolution,
          final_classification,
          final_date
        ]

      30 ->
        [
          _id,
          _notification_datetime,
          symptoms_datetime,
          birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _test_status,
          _test_date,
          _test_type,
          test_result,
          _origin_country,
          gender,
          _residence_state,
          _residence_state_id,
          _residence_city,
          residence_city_id,
          _origin,
          _cnes,
          _notification_state,
          _notification_state_id,
          _notification_city,
          _notification_city_id,
          _removed,
          _validated,
          age,
          final_date,
          case_evolution,
          final_classification
        ] = line

        [
          residence_city_id,
          symptoms_datetime,
          birth_date,
          age,
          gender,
          is_health_professional,
          test_result,
          case_evolution,
          final_classification,
          final_date
        ]

      31 ->
        [
          _id,
          _notification_datetime,
          symptoms_datetime,
          birth_date,
          _symptoms,
          is_health_professional,
          _cbo,
          _conditions,
          _conditions_2,
          _conditions_3,
          _test_status,
          _test_date,
          _test_type,
          test_result,
          _origin_country,
          gender,
          _residence_state,
          _residence_state_id,
          _residence_city,
          residence_city_id,
          _origin,
          _notification_state,
          _notification_state_id,
          _notification_city,
          _notification_city_id,
          _removed,
          _validated,
          age,
          final_date,
          case_evolution,
          final_classification
        ] = line

        [
          residence_city_id,
          symptoms_datetime,
          birth_date,
          age,
          gender,
          is_health_professional,
          test_result,
          case_evolution,
          final_classification,
          final_date
        ]
    end
  end

  defp write(content, file) do
    IO.binwrite(file, content)
  end

  defp finish_extraction(file_path) do
    dir_path = Path.dirname(file_path)
    filename = Path.basename(file_path, ".csv")

    Logger.info("Zipping file")

    {_result, 0} = System.cmd("zip", ~w(#{Path.join(dir_path, filename)} #{file_path}))
  end
end
