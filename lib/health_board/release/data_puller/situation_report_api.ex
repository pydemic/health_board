defmodule HealthBoard.Release.DataPuller.SituationReportAPI do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod"
  plug Tesla.Middleware.JSON

  @spec get_situation_report_summary ::
          {:error, :error_during_get_report_summary}
          | {:ok, %{last_update_date: {:error, :invalid_datetime} | Date.t(), url: any}}
  def get_situation_report_summary do
    case get("/PortalGeralApi") do
      {:ok, tesla_result} ->
        {:ok, %{last_update_date: get_last_update(tesla_result), url: get_file_url(tesla_result)}}

      _ ->
        {:error, :error_during_get_report_summary}
    end
  end

  defp get_last_update(tesla_result) do
    last_update = tesla_result.body["dt_updated"]

    parse_datetime(last_update)
  end

  defp parse_datetime(datetime) do
    case NaiveDateTime.from_iso8601(datetime) do
      {:ok, datetime} ->
        NaiveDateTime.to_date(datetime)

      _error ->
        {:error, :invalid_datetime}
    end
  end

  defp get_file_url(tesla_result) do
    tesla_result.body["planilha"]["arquivo"]["url"]
  end
end
