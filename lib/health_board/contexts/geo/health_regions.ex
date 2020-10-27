defmodule HealthBoard.Contexts.Geo.HealthRegions do
  alias HealthBoard.Contexts.Geo.HealthRegion
  alias HealthBoard.Repo

  @spec get!(integer()) :: %HealthRegion{} | nil
  def get!(id) do
    Repo.get!(HealthRegion, id)
  end

  @spec create(map()) :: {:ok, %HealthRegion{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %HealthRegion{}
    |> HealthRegion.changeset(attrs)
    |> Repo.insert()
  end
end
