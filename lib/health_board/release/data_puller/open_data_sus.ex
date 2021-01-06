defmodule HealthBoard.Release.DataPuller.OpenDataSUS do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://opendatasus.saude.gov.br/api/3"
  plug Tesla.Middleware.JSON

  def get_flu_syndrome_source_information do
    case get("/action/package_show?id=casos-nacionais") do
      {:ok, tesla_result} ->
        {:ok,
         %{last_update_date: get_last_update_flu_syndrome(tesla_result), urls: get_urls_flu_syndrome!(tesla_result)}}

      _ ->
        {:error, "Tesla can't get flu dyndrome"}
    end
  end

  defp get_last_update_flu_syndrome(tesla_result) do
    last_update = tesla_result.body["result"]["metadata_modified"]

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

  defp get_urls_flu_syndrome!(tesla_result) do
    resources = tesla_result.body["result"]["resources"]

    resources
    |> Enum.filter(&(&1["format"] == "CSV"))
    |> Enum.map(& &1["url"])
  end

  def get_sars_source_information do
    case get("/action/package_show?id=bd-srag-2020") do
      {:ok, tesla_result} ->
        {:ok, %{last_update_date: get_last_update_sars!(tesla_result), url: get_url_sars!(tesla_result)}}

      _ ->
        {:error, "Tesla can't get flu dyndrome"}
    end
  end

  defp get_last_update_sars!(tesla_result) do
    get_url_sars!(tesla_result)
    |> get_filename!()
    |> get_date_from_filename!()
  end

  defp get_url_sars!(tesla_result) do
    resources = tesla_result.body["result"]["resources"]

    find_resource_with_format_csv!(resources)["url"]
  end

  defp find_resource_with_format_csv!(resources) do
    Enum.find(resources, "", &(&1["format"] == "CSV"))
  end

  defp get_filename!(url) do
    url
    |> String.split("/")
    |> List.last()
  end

  defp get_date_from_filename!(filename) do
    date =
      filename
      |> String.replace(".csv", "")
      |> String.replace("INFLUD-", "")
      |> String.split("-")

    {:ok, date} =
      Date.new(
        String.to_integer(Enum.at(date, 2)),
        String.to_integer(Enum.at(date, 1)),
        String.to_integer(Enum.at(date, 0))
      )

    date
  end
end
