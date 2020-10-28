defmodule HealthBoard.Contexts.Demographic.HealthRegionsPopulation do
  alias HealthBoard.Contexts.Demographic.HealthRegionPopulation
  alias HealthBoard.Repo

  @spec create(map()) :: {:ok, %HealthRegionPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %HealthRegionPopulation{}
    |> HealthRegionPopulation.changeset(attrs)
    |> Repo.insert()
  end
end
