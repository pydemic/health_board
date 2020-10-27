defmodule HealthBoard.Contexts.Geo.States do
  alias HealthBoard.Contexts.Geo.State
  alias HealthBoard.Repo

  @spec get!(integer()) :: %State{}
  def get!(id) do
    Repo.get!(State, id)
  end

  @spec create(map()) :: {:ok, %State{}} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %State{}
    |> State.changeset(attrs)
    |> Repo.insert()
  end
end
