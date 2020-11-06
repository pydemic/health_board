defmodule HealthBoard.Contexts.Info.Dashboards do
  alias HealthBoard.Contexts.Info.Dashboard
  alias HealthBoard.Repo

  @spec list :: list(%Dashboard{})
  def list do
    Repo.all(Dashboard)
  end

  @spec get(String.t()) :: {:ok, %Dashboard{}} | {:error, :not_found}
  def get(id) do
    case Repo.get(Dashboard, id) do
      nil -> {:error, :not_found}
      dashboard -> {:ok, dashboard}
    end
  end

  @spec get(String.t(), keyword()) :: {:ok, %Dashboard{}} | {:error, :not_found}
  def get(id, opts) do
    if Keyword.get(opts, :preload_all?, false) do
      case Repo.preload(Repo.get(Dashboard, id), [:filters, :indicators_visualizations]) do
        nil -> {:error, :not_found}
        dashboard -> {:ok, dashboard}
      end
    else
      get(id)
    end
  end

  @spec create(map()) :: {:ok, %Dashboard{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Dashboard{}
    |> Dashboard.changeset(attrs)
    |> Repo.insert()
  end
end
