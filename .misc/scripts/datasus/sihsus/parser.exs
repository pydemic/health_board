defmodule HealthBoard.Scripts.DATASUS.SIHSUS.Parser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")

  @sources_dir Path.join(@dir, "rddf")
  @result_file_path Path.join(@dir, "DERM_DF.csv")
  @headers ~w[ano mes cnpj cid_10 sexo idade dias_uti dias_ui dias_perm valor obito]

  @spec run :: :ok
  def run do
    File.rm_rf!(@result_file_path)
    result_file = File.open!(@result_file_path, [:append])
    IO.write(result_file, Enum.join(@headers, ",") <> "\n")

    try do
      @sources_dir
      |> File.ls!()
      |> Stream.with_index(1)
      |> Task.async_stream(&parse_file_and_append_to_csv(&1, result_file), timeout: :infinity)
      |> Stream.run()
    rescue
      error ->
        Logger.error(Exception.message(error) <> "\n" <> Exception.format_stacktrace(__STACKTRACE__))
    end

    File.close(result_file)
  end

  defp parse_file_and_append_to_csv({file_name, file_index}, result_file) do
    Logger.info("[#{file_index}] Parsing #{file_name}")

    @sources_dir
    |> Path.join(file_name)
    |> File.stream!()
    |> NimbleCSV.RFC4180.parse_stream(skip_headers: false)
    |> Enum.reduce({[], nil}, &parse_line/2)
    |> elem(0)
    |> append_to_csv(result_file)
  end

  defp parse_line(line, {list, nil}) do
    {list, Enum.reduce(Enum.with_index(line), %{}, &parse_index/2)}
  end

  defp parse_index({column, index}, map) do
    case column do
      "ANO_CMPT" -> Map.put(map, :year, index)
      "MES_CMPT" -> Map.put(map, :month, index)
      "CGC_HOSP" -> Map.put(map, :cnpj, index)
      "MUNIC_RES" -> Map.put(map, :city_id, index)
      "SEXO" -> Map.put(map, :sex, index)
      "UTI_MES_TO" -> Map.put(map, :days_icu, index)
      "UTI_INT_TO" -> Map.put(map, :days_intermediary, index)
      "VAL_TOT" -> Map.put(map, :value, index)
      "DIAG_PRINC" -> Map.put(map, :disease_id, index)
      "IDADE" -> Map.put(map, :age, index)
      "DIAS_PERM" -> Map.put(map, :days_stay, index)
      "MORTE" -> Map.put(map, :death, index)
      _column -> map
    end
  end

  defp parse_line(line, {list, indexes}) do
    city_id = Enum.at(line, indexes.city_id)

    if String.slice(city_id, 0, 2) == "53" do
      disease_id = Enum.at(line, indexes.disease_id)

      if disease_id in ~w[L20 L200 L208 L209 L210 L211 L218 L219] do
        {
          [
            [
              optional(&String.to_integer/1, Enum.at(line, indexes.year)),
              optional(&String.to_integer/1, Enum.at(line, indexes.month)),
              optional(&String.to_integer/1, Enum.at(line, indexes.cnpj)),
              disease_id,
              optional(&String.to_integer/1, Enum.at(line, indexes.sex)),
              optional(&String.to_integer/1, Enum.at(line, indexes.age)),
              optional(&String.to_integer/1, Enum.at(line, indexes.days_icu)),
              optional(&String.to_integer/1, Enum.at(line, indexes.days_intermediary)),
              optional(&String.to_integer/1, Enum.at(line, indexes.days_stay)),
              optional(&String.to_float/1, Enum.at(line, indexes.value)),
              optional(&String.to_integer/1, Enum.at(line, indexes.death))
            ]
          ] ++ list,
          indexes
        }
      else
        {list, indexes}
      end
    else
      {list, indexes}
    end
  end

  defp optional(function, value) do
    function.(value)
  rescue
    _error -> nil
  end

  defp append_to_csv(lines, result_file) do
    Enum.each(lines, &write_line(&1, result_file))
  end

  defp write_line(line, result_file) do
    IO.write(result_file, Enum.join(line, ",") <> "\n")
  end
end

HealthBoard.Scripts.DATASUS.SIHSUS.Parser.run()
