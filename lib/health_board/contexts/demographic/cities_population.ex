defmodule HealthBoard.Contexts.Demographic.CitiesPopulation do
  alias HealthBoard.Contexts.Demographic.CityPopulation
  alias HealthBoard.Repo

  @spec create(map()) :: {:ok, %CityPopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %CityPopulation{}
    |> CityPopulation.changeset(attrs)
    |> Repo.insert()
  end
end
