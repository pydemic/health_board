defmodule HealthBoard.Release.DataPuller.ExternalServices.SituationReport do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod"
  plug Tesla.Middleware.Headers, [{"x-parse-application-id", "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"}]
  plug Tesla.Middleware.JSON

  def get_situation_report do
    case get("/PortalGeral") do
      {:ok, tesla_result} ->
        {:ok, %{last_update_date: get_last_update(tesla_result), url: get_url_file!(tesla_result)}}

      _ ->
        {:error, :error_during_get_report_summary}
    end
  end

  defp get_last_update(tesla_result) do
    last_update = Enum.at(tesla_result.body["results"], 0)["updatedAt"]

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

  defp get_url_file!(tesla_result) do
    Enum.at(tesla_result.body["results"], 0)["arquivo"]["url"]
  end
end
