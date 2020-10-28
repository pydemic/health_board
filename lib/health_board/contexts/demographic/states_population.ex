defmodule HealthBoard.Contexts.Demographic.StatesPopulation do
  alias HealthBoard.Contexts.Demographic.StatePopulation
  alias HealthBoard.Repo

  @spec create(map()) :: {:ok, %StatePopulation{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %StatePopulation{}
    |> StatePopulation.changeset(attrs)
    |> Repo.insert()
  end
end
