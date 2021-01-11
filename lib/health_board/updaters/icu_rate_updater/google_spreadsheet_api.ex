defmodule HealthBoard.Updaters.ICURateUpdater.GoogleSpreadsheetAPI do
  use Tesla

  require Logger

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

  plug Tesla.Middleware.BaseUrl, "https://sheets.googleapis.com/v4/spreadsheets/"
  plug Tesla.Middleware.JSON

  @spec extract(String.t()) :: {:ok, map} | {:error, atom}
  def extract(dir) do
    with {:ok, id} <- Application.fetch_env(:health_board, :spreadsheet_id),
         {:ok, page} <- Application.fetch_env(:health_board, :spreadsheet_page),
         {:ok, key} <- Application.fetch_env(:health_board, :google_api_key) do
      case get("/#{id}/values/#{page}?key=#{key}") do
        {:ok, %{body: data}} -> {:ok, parse_and_write_data(data, dir)}
        _error -> {:error, :request_failed}
      end
    end
  end

  defp parse_and_write_data(data, dir) do
    case parse_data(data) do
      {:ok, %{records: records, updated_at: updated_at}} ->
        records
        |> Enum.sort_by(& &1.date, Date)
        |> Enum.sort_by(& &1.location_id, &<=/2)
        |> Enum.map(&Enum.join([&1.location_id, &1.date, &1.icu_rate], ","))
        |> Enum.join("\n")
        |> write_to_file(dir)

        %{updated_at: updated_at}

      error ->
        error
    end
  end

  defp parse_data(data) do
    case data do
      %{"values" => values} -> {:ok, parse_values(values)}
      _data -> {:error, :invalid_data}
    end
  end

  defp parse_values(values) do
    values =
      values
      |> Enum.with_index()
      |> Enum.drop(1)

    {records, updated_at} = Enum.reduce(values, {[], Date.from_erl!({0, 1, 1})}, &parse_line/2)
    %{records: Enum.uniq_by(records, &{&1.location_id, &1.date}), updated_at: updated_at}
  end

  defp parse_line({line, line_index}, {records, updated_at}) do
    case do_parse_line(line) do
      {%{date: date} = state_record, city_record} ->
        {[state_record, city_record] ++ records, latest_date(date, updated_at)}

      %{date: date} = record ->
        {[record | records], latest_date(date, updated_at)}

      nil ->
        {records, updated_at}
    end
  rescue
    error ->
      Logger.error("[#{line_index}] Failed to parse line. Reason: #{inspect(error)}")
      {records, updated_at}
  end

  defp do_parse_line(line) do
    line
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, &parse_by_index/2)
    |> case do
      {%{icu_rate: _} = state_record, %{icu_rate: _} = city_record} -> {state_record, city_record}
      {%{icu_rate: _} = state_record, _city_record} -> state_record
      {_state_record, %{icu_rate: _} = city_record} -> city_record
      _result -> nil
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp parse_by_index({cell, cell_index}, {state_record, city_record}) do
    case cell_index do
      0 ->
        date = parse_date(cell)
        {Map.put(state_record, :date, date), Map.put(city_record, :date, date)}

      2 ->
        {state_id, city_id} = parse_state_abbr(cell)
        {Map.put(state_record, :location_id, state_id), Map.put(city_record, :location_id, city_id)}

      3 ->
        case parse_icu_rate(cell) do
          nil -> {state_record, city_record}
          icu_rate -> {Map.put(state_record, :icu_rate, icu_rate), city_record}
        end

      5 ->
        case parse_icu_rate(cell) do
          nil -> {state_record, city_record}
          icu_rate -> {state_record, Map.put(city_record, :icu_rate, icu_rate)}
        end

      _index ->
        {state_record, city_record}
    end
  end

  defp parse_date(date) do
    date
    |> String.split("/")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reverse()
    |> List.to_tuple()
    |> Date.from_erl!()
  end

  defp parse_state_abbr(state_abbr) do
    Map.fetch!(@states, state_abbr)
  end

  defp parse_icu_rate(icu_rate) do
    if is_integer(icu_rate) do
      icu_rate
    else
      String.to_integer(icu_rate)
    end
  rescue
    _error -> nil
  end

  defp latest_date(date1, date2) do
    if Date.compare(date1, date2) == :gt do
      date1
    else
      date2
    end
  end

  defp write_to_file(data, dir) do
    dir = Path.join(dir, "daily_icu_rate")

    File.rm_rf!(dir)
    File.mkdir_p!(dir)

    dir
    |> Path.join("daily_icu_rate.csv")
    |> File.write!(data)

    :ok
  end
end
