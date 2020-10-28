defmodule HealthBoard.Contexts.Demographic.RegionsPopulation do
  alias HealthBoard.Contexts.Demographic.RegionPopulation
  alias HealthBoard.Repo

  @spec create(map()) :: {:ok, %RegionPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %RegionPopulation{}
    |> RegionPopulation.changeset(attrs)
    |> Repo.insert()
  end
end
