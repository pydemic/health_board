defmodule HealthBoard.Updaters.FluSyndromeUpdater.HeaderAPI do
  use Tesla

  @path "/action/package_show?id=casos-nacionais"

  plug Tesla.Middleware.BaseUrl, "https://opendatasus.saude.gov.br/api/3"
  plug Tesla.Middleware.JSON

  @spec get :: {:ok, map} | {:error, atom}
  def get do
    case get(@path) do
      {:ok, %{body: data}} -> parse_data(data)
      _error -> {:error, :request_failed}
    end
  end

  defp parse_data(data) do
    with {:ok, resources} <- find_resources(data),
         {:ok, resources} <- filter_resources(resources),
         {:ok, urls} <- find_urls(resources),
         {:ok, metadata_modified} <- find_metadata_modified(data),
         {:ok, updated_at} <- parse_datetime(metadata_modified) do
      {:ok, %{updated_at: updated_at, urls: urls}}
    end
  end

  defp find_resources(%{"result" => %{"resources" => resources}}), do: {:ok, resources}
  defp find_resources(_data), do: {:error, :resources_not_found}

  defp filter_resources(resources) do
    case Enum.filter(resources, &(Map.get(&1, "format") == "CSV")) do
      [] -> {:error, :csv_resource_not_found}
      resources -> {:ok, resources}
    end
  end

  defp find_urls(resources) do
    urls = Enum.map(resources, &find_url(&1))

    if Enum.any?(urls, &(&1 == {:error, :resource_url_not_found})) do
      {:error, :some_resource_url_not_found}
    else
      {:ok, Enum.map(urls, &elem(&1, 1))}
    end
  end

  defp find_url(%{"url" => url}), do: {:ok, url}
  defp find_url(_resource), do: {:error, :resource_url_not_found}

  defp find_metadata_modified(%{"result" => %{"metadata_modified" => metadata_modified}}), do: {:ok, metadata_modified}
  defp find_metadata_modified(_resource), do: {:error, :resource_metadata_modified_not_found}

  defp parse_datetime(datetime) do
    case NaiveDateTime.from_iso8601(datetime) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> {:error, :invalid_datetime}
    end
  end
end
