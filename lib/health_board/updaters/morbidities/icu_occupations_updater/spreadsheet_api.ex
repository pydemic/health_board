defmodule HealthBoard.Updaters.ICUOccupationsUpdater.SpreadsheetAPI do
  require Logger

  defstruct url: "https://sheets.googleapis.com/v4/spreadsheets/",
            spreadsheet_id: nil,
            spreadsheet_page: nil,
            token: nil,
            token_scope: "https://www.googleapis.com/auth/spreadsheets.readonly",
            group_id: nil,
            output_path: nil

  @spec get(keyword) :: {:ok, Date.t()} | {:error, atom}
  def get(opts \\ []) do
    with {:ok, api_data} <- parse_opts(opts) do
      case Tesla.get(client(api_data), URI.encode("/#{api_data.spreadsheet_id}/values/#{api_data.spreadsheet_page}")) do
        {:ok, %{body: %{"values" => values}}} ->
          handle_values(values, api_data.group_id, api_data.output_path)

        error ->
          IO.inspect(error)
          {:error, :request_failed}
      end
    end
  end

  defp parse_opts(opts) do
    %{token_scope: scope} = api_data = struct(__MODULE__, opts)

    binary_data = [api_data.url, api_data.spreadsheet_id, api_data.spreadsheet_page, scope, api_data.output_path]

    with true <- Enum.all?(binary_data, &is_binary/1),
         true <- is_integer(api_data.group_id),
         {:ok, %{token: token}} <- Goth.Token.for_scope(scope) do
      {:ok, Map.put(api_data, :token, token)}
    else
      _result -> {:error, :missing_spreadsheet_api_data}
    end
  end

  defp client(api_data) do
    middleware = [
      {Tesla.Middleware.BaseUrl, api_data.url},
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_data.token}"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  defp handle_values(values, group_id, output_path) do
    with {:ok, {records, updated_at}} <- parse_values(values),
         :ok <- write_records(records, group_id, output_path) do
      {:ok, updated_at}
    end
  end

  defp parse_values(values) do
    if is_list(values) and Enum.any?(values) do
      values
      |> Enum.with_index()
      |> Enum.drop(1)
      |> Enum.reduce({[], Date.from_erl!({0, 1, 1})}, &parse_line/2)
      |> case do
        {[_ | _] = records, updated_at} -> {:ok, {unique_records(records), updated_at}}
        _result -> {:error, :invalid_spreadsheet_data}
      end
    else
      {:error, :empty_spreadsheet}
    end
  end

  defp parse_line({line, line_index}, {records, updated_at}) do
    case do_parse_line(line) do
      {%{date: date} = state_record, city_record} ->
        {[state_record, city_record | records], latest_date(updated_at, date)}

      %{date: date} = record ->
        {[record | records], latest_date(updated_at, date)}

      _result ->
        {records, updated_at}
    end
  rescue
    error ->
      Logger.error("[#{line_index}] Failed to parse line. Reason: #{inspect(error)}")
      {records, updated_at}
  end

  @states %{
    "AC" => {12, 1_200_401},
    "AL" => {27, 2_704_302},
    "AM" => {13, 1_302_603},
    "AP" => {16, 1_600_303},
    "BA" => {29, 2_927_408},
    "CE" => {23, 2_304_400},
    "DF" => {53, 5_300_108},
    "ES" => {32, 3_205_309},
    "GO" => {52, 5_208_707},
    "MA" => {21, 2_111_300},
    "MG" => {31, 3_106_200},
    "MS" => {50, 5_002_704},
    "MT" => {51, 5_103_403},
    "PA" => {15, 1_501_402},
    "PB" => {25, 2_507_507},
    "PE" => {26, 2_611_606},
    "PI" => {22, 2_211_001},
    "PR" => {41, 4_106_902},
    "RJ" => {33, 3_304_557},
    "RN" => {24, 2_408_102},
    "RO" => {11, 1_100_205},
    "RR" => {14, 1_400_100},
    "RS" => {43, 4_314_902},
    "SC" => {42, 4_205_407},
    "SE" => {28, 2_800_308},
    "SP" => {35, 3_550_308},
    "TO" => {17, 1_721_000}
  }

  defp do_parse_line(line) do
    line
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, &parse_by_index/2)
    |> validate_records()
  end

  defp parse_by_index({cell, cell_index}, {state_record, city_record}) do
    case cell_index do
      1 -> parse_date(cell, state_record, city_record)
      3 -> parse_state_abbr(cell, state_record, city_record)
      4 -> {parse_icu_occupation_rate(cell, state_record), city_record}
      6 -> {state_record, parse_icu_occupation_rate(cell, city_record)}
      7 -> parse_link(cell, state_record, city_record)
      8 -> parse_link(cell, state_record, city_record)
      _ -> {state_record, city_record}
    end
  end

  defp parse_date(cell, state_record, city_record) do
    date =
      cell
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()
      |> List.to_tuple()
      |> Date.from_erl!()

    {Map.put(state_record, :date, date), Map.put(city_record, :date, date)}
  end

  defp parse_state_abbr(cell, state_record, city_record) do
    {state_id, city_id} = Map.fetch!(@states, cell)
    {Map.put(state_record, :location_id, state_id), Map.put(city_record, :location_id, city_id)}
  end

  defp parse_icu_occupation_rate(cell, record) do
    Map.put(record, :icu_occupation_rate, if(is_integer(cell), do: cell, else: String.to_integer(cell)))
  rescue
    _error -> record
  end

  defp parse_link(cell, state_record, city_record) do
    cell = List.first(String.split(cell, " ", trim: true))
    URI.decode(cell)

    {
      if(Map.has_key?(state_record, :link), do: state_record, else: Map.put(state_record, :link, cell)),
      Map.put(city_record, :link, cell)
    }
  rescue
    _error -> {state_record, city_record}
  end

  defp validate_records({state_record, city_record}) do
    case {is_record_valid?(state_record), is_record_valid?(city_record)} do
      {true, true} -> {state_record, city_record}
      {true, _false} -> state_record
      {_false, true} -> city_record
      _result -> nil
    end
  end

  defp is_record_valid?(%{icu_occupation_rate: _}), do: true
  defp is_record_valid?(_record), do: false

  defp latest_date(d1, d2) do
    if Date.compare(d1, d2) == :gt do
      d1
    else
      d2
    end
  end

  defp unique_records(records), do: Enum.uniq_by(records, &{&1.location_id, &1.date})

  defp write_records(records, group_id, output_path) do
    records
    |> Enum.sort(&(Date.compare(&1.date, &2.date) != :lt and &1.location_id <= &2.location_id))
    |> Enum.map(&[group_id, &1.location_id, &1.date, &1.icu_occupation_rate, &1[:link]])
    |> NimbleCSV.RFC4180.dump_to_iodata()
    |> do_write_records(output_path)
  end

  defp do_write_records(content, output_path) do
    File.rm_rf!(output_path)
    File.mkdir_p!(output_path)

    with {:error, _reason} <- File.write(Path.join(output_path, "0000.csv"), content) do
      {:error, :failed_to_write_records}
    end
  end
end
