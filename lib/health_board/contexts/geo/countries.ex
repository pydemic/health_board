defmodule HealthBoard.Contexts.Geo.Countries do
  alias HealthBoard.Contexts.Geo.Country
  alias HealthBoard.Repo

  @spec get!(integer()) :: %Country{}
  def get!(id) do
    Repo.get!(Country, id)
  end

  @spec create(map()) :: {:ok, %Country{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Country{}
    |> Country.changeset(attrs)
    |> Repo.insert()
  end
end
