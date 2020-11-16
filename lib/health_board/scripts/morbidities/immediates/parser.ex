defmodule HealthBoard.Scripts.Morbidities.Immediates.Parser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")

  @common_columns [
    {"DT_NOTIFIC", :date, :required},
    {"ID_MUNICIP", :integer, :required},
    {"ID_MN_RESI", :integer, :required},
    {"NU_IDADE_N", :integer, :optional},
    {"CS_SEXO", :string, :optional},
    {"CS_RACA", :integer, :optional},
    {"CLASSI_FIN", :integer, :optional}
  ]

  @column_evolution {"EVOLUCAO", :integer, :optional}

  @botulism_columns @common_columns ++ [@column_evolution, {"TPBOTULISM", :integer, :optional}]
  @chikungunya_columns @common_columns ++ [@column_evolution]
  @cholera_columns @common_columns ++ [@column_evolution, {"VINCULO", :integer, :optional}]
  @yellow_fever_columns @common_columns ++ [@column_evolution, {"VACINADO", :integer, :optional}]
  @spotted_fever_columns @common_columns ++ [@column_evolution]
  @hantavirus_columns @common_columns ++ [@column_evolution, {"CON_AMBIEN", :integer, :optional}]
  @malaria_from_extra_amazon_columns @common_columns ++ [{"RESULT", :integer, :optional}]
  @plague_columns @common_columns ++
                    [@column_evolution, {"CON_CLASSI", :integer, :optional}, {"CON_GRAVID", :integer, :optional}]
  @human_rabies_columns @common_columns ++ [{"ESPECIE_N", :integer, :optional}, {"TRA_SORO", :integer, :optional}]
  @zika_columns @common_columns ++ [@column_evolution]

  @diseases %{
    "BOTU" => {"botulism", @botulism_columns},
    "CHIK" => {"chikungunya", @chikungunya_columns},
    "COLE" => {"cholera", @cholera_columns},
    "FAMA" => {"yellow_fever", @yellow_fever_columns},
    "FMAC" => {"spotted_fever", @spotted_fever_columns},
    "HANT" => {"hantavirus", @hantavirus_columns},
    "MALA" => {"malaria_from_extra_amazon", @malaria_from_extra_amazon_columns},
    "PEST" => {"plague", @plague_columns},
    "RAIV" => {"human_rabies", @human_rabies_columns},
    "ZIKA" => {"zika", @zika_columns}
  }

  @spec run :: :ok
  def run do
    File.rm_rf!(@output_dir)
    File.mkdir_p!(@output_dir)

    @input_dir
    |> File.ls!()
    |> inform_files()
    |> Stream.with_index(1)
    |> Task.async_stream(&parse_data_and_append_to_csv/1, timeout: :infinity)
    |> Stream.run()

    @output_dir
    |> File.ls!()
    |> Enum.each(&sort_file/1)
  end

  defp inform_files(file_names) do
    Logger.info("#{Enum.count(file_names)} files identified")
    file_names
  end

  defp parse_data_and_append_to_csv({file_name, file_index}) do
    if rem(file_index, 500) == 0 do
      Logger.info("[#{file_index}] Parsing #{file_name}")
    end

    {result_file_name, columns} = Map.get(@diseases, String.slice(file_name, 0, 4))

    file_path = Path.join(@output_dir, result_file_name <> ".csv")
    file = File.open!(file_path, [:append])

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> parse_and_append_to_csv(file, columns)

    File.close(file)
  end

  defp parse_and_append_to_csv(stream, file, columns) do
    [first_line] = Enum.to_list(Stream.take(stream, 1))
    indexes = Enum.map(columns, &parse_index(first_line, &1))

    stream
    |> Stream.drop(1)
    |> Stream.map(&parse_line_and_append_to_csv(&1, indexes, file))
    |> Stream.run()
  end

  defp parse_index(line, {column_name, type, required_or_optional}) do
    case {Enum.find_index(line, &(&1 == column_name)), required_or_optional} do
      {nil, :required} -> raise "Column #{column_name} not found"
      {index, _required_or_optional} -> {index, type, required_or_optional}
    end
  end

  defp parse_line_and_append_to_csv(line, indexes, file) do
    indexes
    |> Enum.map(&parse_item(line, &1))
    |> append_to_csv(file)
  end

  defp parse_item(line, {index, type, required_or_optional}) do
    case {Enum.at(line, index), type, required_or_optional} do
      {"", _type, :required} -> raise "Data at column #{index} is empty"
      {"N/A", _type, :required} -> raise "Data at column #{index} not defined"
      {value, type, :required} -> parse_value(value, type) || raise "Data at column #{index} is invalid"
      {value, type, _required_or_optional} -> parse_value(value, type)
    end
  end

  defp parse_value(value, type) do
    case type do
      :integer -> String.to_integer(value)
      :string -> sanitize_string(value)
      :date -> Date.from_iso8601!(value)
    end
  rescue
    _error -> nil
  end

  defp sanitize_string(value) do
    if String.replace(value, "*", "") != "" do
      if String.contains?(value, ",") do
        ~s("#{value}")
      else
        value
      end
    else
      nil
    end
  end

  defp append_to_csv(line, file) do
    IO.write(file, Enum.join(line, ",") <> "\n")
  end

  defp sort_file(file_name) do
    Logger.info("Sorting #{Path.basename(file_name)}")

    file_path = Path.join(@output_dir, file_name)

    {_result, 0} = System.cmd("sort", ~w[-o #{file_path} #{file_path}])
  end
end
