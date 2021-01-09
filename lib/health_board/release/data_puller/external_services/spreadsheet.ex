defmodule HealthBoard.Release.DataPuller.ExternalServices.Spreadsheet do
  require Logger

  use Tesla

  @app :health_board

  plug Tesla.Middleware.BaseUrl, "https://sheets.googleapis.com/v4/spreadsheets/"
  plug Tesla.Middleware.JSON

  @spec get_spreadsheet :: :error | %{last_update_date: Date.t(), spreadsheet: [any]}
  def get_spreadsheet do
    spreadsheet_id = Application.fetch_env!(@app, :spreadsheet_id)
    spreadsheet_page = Application.fetch_env!(@app, :spreadsheet_page)
    key = Application.fetch_env!(@app, :google_api_key)

    Logger.info("Getting spreadsheet values from API")

    case get("/#{spreadsheet_id}/values/#{spreadsheet_page}?key=#{key}") do
      {:ok, result} -> extract_spreadsheet_information(result)
      _error -> :error
    end
  end

  defp extract_spreadsheet_information(result) do
    case get_only_values(result) do
      :error ->
        :error

      values ->
        case get_last_update(values) do
          {:ok, last_update_date} -> %{last_update_date: last_update_date, spreadsheet: values}
          _error -> :error
        end
    end
  end

  defp get_only_values(result) do
    case List.pop_at(result.body["values"], 0) do
      {nil, _values} -> :error
      {_value_removed, values} -> values
    end
  end

  defp get_last_update(values) do
    date = get_date(values)

    day = String.to_integer(Enum.at(date, 0))
    month = String.to_integer(Enum.at(date, 1))
    year = String.to_integer(Enum.at(date, 2))

    case Date.new(year, month, day) do
      {:ok, date} -> {:ok, date}
      _error -> :error
    end
  end

  defp get_date(values) do
    values
    |> List.last()
    |> List.first()
    |> String.split("/")
  end
end
