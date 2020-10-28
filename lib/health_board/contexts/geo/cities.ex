defmodule HealthBoard.Contexts.Geo.Cities do
  alias HealthBoard.Contexts.Geo.City
  alias HealthBoard.Repo

  @spec list :: list(%City{})
  def list do
    Repo.all(City)
  end

  @spec create(map()) :: {:ok, %City{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %City{}
    |> City.changeset(attrs)
    |> Repo.insert()
  end
end
