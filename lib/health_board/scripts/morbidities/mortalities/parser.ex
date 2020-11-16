defmodule HealthBoard.Scripts.Morbidities.Mortalities.Parser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")

  @columns [
    {"DTOBITO", :date, :required},
    {"CAUSABAS", :string, :required},
    {"CODMUNOCOR", :integer, :required},
    {"CODMUNRES", :integer, :required},
    {"IDADE", :integer, :optional},
    {"SEXO", :integer, :optional},
    {"RACACOR", :integer, :optional},
    {"TIPOBITO", :integer, :optional},
    {"TPPOS", :integer, :optional}
  ]

  @file_name "mortalities"

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
    if rem(file_index, 50) == 0 do
      Logger.info("[#{file_index}] Parsing #{file_name}")
    end

    file_path = Path.join(@output_dir, @file_name <> ".csv")
    file = File.open!(file_path, [:append])

    @input_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> parse_and_append_to_csv(file, @columns)

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

  defp parse_index(line, {column_names, type, required_or_optional}) when is_list(column_names) do
    column_names
    |> Enum.map(&parse_index(line, {&1, type, :optional}))
    |> Enum.map(&elem(&1, 0))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        if(required_or_optional == :required, do: raise("Columns not found"), else: {nil, type, required_or_optional})

      indexes ->
        {indexes, type, required_or_optional}
    end
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

  defp parse_item(line, {indexes, type, required_or_optional}) when is_list(indexes) do
    indexes
    |> Enum.map(&parse_item(line, {&1, type, :optional}))
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> if(required_or_optional == :required, do: raise("Data not found"), else: nil)
      [value | _values] -> value
    end
  end

  defp parse_item(line, {index, type, required_or_optional}) do
    if is_nil(index) do
      nil
    else
      case {Enum.at(line, index), type, required_or_optional} do
        {"", _type, :required} -> raise "Data at column #{index} is empty"
        {"N/A", _type, :required} -> raise "Data at column #{index} not defined"
        {value, type, :required} -> parse_value(value, type) || raise "Data at column #{index} (#{value}) is invalid"
        {value, type, _required_or_optional} -> parse_value(value, type)
      end
    end
  end

  defp parse_value(value, type) do
    case type do
      :integer -> String.to_integer(value)
      :string -> sanitize_string(value)
      :date -> parse_date!(value)
    end
  rescue
    _error -> nil
  end

  defp parse_date!(value) do
    if value == "" do
      nil
    else
      case String.length(value) do
        4 ->
          String.to_integer(value)

        6 ->
          value
          |> String.slice(2, 4)
          |> String.to_integer()

        8 ->
          value
          |> String.slice(4, 4)
          |> String.to_integer()

        _ ->
          nil
      end
    end
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
