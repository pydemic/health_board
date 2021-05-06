defmodule HealthBoard.Updaters.CovidVaccinesUpdater.HeaderAPI do
  defstruct url: "https://opendatasus.saude.gov.br/api/3/action/package_show?id=covid-19-vacinacao"

  @spec get(keyword) :: {:ok, map} | {:error, atom}
  def get(opts \\ []) do
    case Tesla.get(client(opts), "") do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp client(opts) do
    api_data = struct(__MODULE__, opts)

    middleware = [
      {Tesla.Middleware.BaseUrl, api_data.url},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  defp parse_data(data) do
    case data do
      %{"result" => %{"resources" => resources, "metadata_modified" => updated_at}} ->
        with {:ok, updated_at} <- parse_datetime(updated_at),
             {:ok, urls} <- fetch_resources_urls(resources) do
          {:ok, %{updated_at: updated_at, urls: urls}}
        end

      _data ->
        {:error, :invalid_data}
    end
  end

  defp fetch_resources_urls(resources) do
    case Enum.reduce(resources, [], &csv_resource_url/2) do
      [] -> {:error, :resources_urls_not_found}
      urls -> {:ok, urls}
    end
  end

  defp csv_resource_url(resource, urls) do
    case resource do
      %{"format" => "CSV", "description" => description} -> extract_url(description)
      _resource -> urls
    end
  end

  defp extract_url(description) do
    url =
      Regex.scan(~r"(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?", description)
      |> List.first()
      |> List.first()

    [url]
  end

  defp parse_datetime(datetime) do
    case NaiveDateTime.from_iso8601(datetime) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> {:error, :invalid_datetime}
    end
  end
end
