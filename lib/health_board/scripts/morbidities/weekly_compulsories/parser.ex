defmodule HealthBoard.Scripts.Morbidities.WeeklyCompulsories.Parser do
  require Logger

  @dir Path.join(File.cwd!(), ".misc/sandbox")
  @input_dir Path.join(@dir, "input")
  @output_dir Path.join(@dir, "output")

  @common_columns [
    {["DT_OCOR", "DT_SIN_PRI", "DT_DIAG", "DT_NOTIFIC", "NU_ANO"], :date, :required},
    {"ID_MUNICIP", :integer, :optional},
    {"ID_MN_RESI", :integer, :required},
    {"NU_IDADE_N", :integer, :optional},
    {"CS_SEXO", :string, :optional},
    {"CS_RACA", :integer, :optional}
  ]

  @column_classification {"CLASSI_FIN", :integer, :optional}

  @poisonous_animals_accidents_columns @common_columns ++ [{"TP_ACIDENT", :integer, :optional}]
  @chagas_columns @common_columns ++ [@column_classification]
  @whooping_cough_columns @common_columns ++ [@column_classification]
  @dengue_columns @common_columns ++ [@column_classification, {"SOROTIPO", :integer, :optional}]
  @diphtheria_columns @common_columns ++ [@column_classification]
  @schistosomiasis_columns @common_columns
  @leprosy_columns @common_columns ++ [{"MODOENTR", :integer, :optional}]
  @exogenous_intoxications_columns @common_columns ++
                                     [
                                       @column_classification,
                                       {"LOC_EXPO", :integer, :optional},
                                       {"AGENTE_TOX", :integer, :optional},
                                       {"DOENCA_TRA", :integer, :optional},
                                       {"TPEXP", :integer, :optional}
                                     ]
  @visceral_leishmaniasis_columns @common_columns ++
                                    [
                                      @column_classification,
                                      {"HIV", :integer, :optional},
                                      {"ENTRADA", :integer, :optional}
                                    ]
  @leptospirosis_columns @common_columns ++
                           [
                             @column_classification,
                             {"DOENCA_TRA", :integer, :optional},
                             {"CON_AREA", :integer, :optional}
                           ]
  @american_tegumentary_leishmaniasis_columns @common_columns ++ [{"CLI_CO_HIV", :integer, :optional}]
  @meningitis_columns @common_columns ++ [@column_classification]
  @tetanus_accidents_columns @common_columns ++
                               [
                                 @column_classification,
                                 {"NU_DOSE", :integer, :optional},
                                 {"TP_PROFILA", :integer, :optional},
                                 {"TP_CAUSA", :integer, :optional},
                                 {"CS_LOCAL", :integer, :optional}
                               ]
  @neonatal_tetanus_columns @common_columns ++
                              [
                                @column_classification,
                                {"CS_VACTETA", :integer, :optional},
                                {"DS_INF_LOC", :integer, :optional},
                                {"NUM_CON_N", :integer, :optional}
                              ]
  @tuberculosis_columns @common_columns ++
                          [
                            {"POP_LIBER", :integer, :optional},
                            {"POP_RUA", :integer, :optional},
                            {"POP_SAUDE", :integer, :optional},
                            {"POP_IMIG", :integer, :optional},
                            {"HIV", :integer, :optional},
                            {"AGRAVAIDS", :integer, :optional},
                            {"AGRAVALCOO", :integer, :optional},
                            {"AGRAVDIABE", :integer, :optional},
                            {"AGRAVDOENC", :integer, :optional},
                            {"AGRAVDROGAS", :integer, :optional},
                            {"AGRAVTABACO", :integer, :optional},
                            {"AGRAVOUTRA", :integer, :optional}
                          ]
  @violence_columns @common_columns

  @diseases %{
    "ANIM" => {"poisonous_animals_accidents", @poisonous_animals_accidents_columns},
    "CHAG" => {"chagas", @chagas_columns},
    "COQU" => {"whooping_cough", @whooping_cough_columns},
    "DENG" => {"dengue", @dengue_columns},
    "DIFT" => {"diphtheria", @diphtheria_columns},
    "ESQU" => {"schistosomiasis", @schistosomiasis_columns},
    "HANS" => {"leprosy", @leprosy_columns},
    "IEXO" => {"exogenous_intoxications", @exogenous_intoxications_columns},
    "LEIV" => {"visceral_leishmaniasis", @visceral_leishmaniasis_columns},
    "LEPT" => {"leptospirosis", @leptospirosis_columns},
    "LTAN" => {"american_tegumentary_leishmaniasis", @american_tegumentary_leishmaniasis_columns},
    "MENI" => {"meningitis", @meningitis_columns},
    "TETA" => {"tetanus_accidents", @tetanus_accidents_columns},
    "TETN" => {"neonatal_tetanus", @neonatal_tetanus_columns},
    "TUBE" => {"tuberculosis", @tuberculosis_columns},
    "VIOL" => {"violence", @violence_columns}
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
        {value, type, :required} -> parse_value(value, type) || raise "Data at column #{index} is invalid"
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
    case Date.from_iso8601(value) do
      {:ok, %{year: year}} -> year
      _error -> String.to_integer(value)
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
