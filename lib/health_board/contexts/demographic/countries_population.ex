defmodule HealthBoard.Contexts.Demographic.CountriesPopulation do
  alias HealthBoard.Contexts.Demographic.CountryPopulation
  alias HealthBoard.Repo

  @spec create(map()) :: {:ok, %CountryPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %CountryPopulation{}
    |> CountryPopulation.changeset(attrs)
    |> Repo.insert()
  end
end
