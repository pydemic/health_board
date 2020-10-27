defmodule HealthBoard.Contexts.Geo.Regions do
  alias HealthBoard.Contexts.Geo.Region
  alias HealthBoard.Repo

  @spec get!(integer()) :: %Region{}
  def get!(id) do
    Repo.get!(Region, id)
  end

  @spec create(map()) :: {:ok, %Region{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Region{}
    |> Region.changeset(attrs)
    |> Repo.insert()
  end
end
