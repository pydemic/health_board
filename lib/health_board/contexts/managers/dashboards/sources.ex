defmodule HealthBoard.Contexts.Dashboards.Sources do
  alias HealthBoard.Contexts.Dashboards.Source
  alias HealthBoard.Repo

  @type schema :: %Source{}

  @schema Source

  @spec fetch(integer) :: {:ok, schema} | {:error, :not_found}
  def fetch(id) do
    case Repo.get(@schema, id) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end

  @spec update(integer, map) :: {:ok, schema} | {:error, Ecto.Changeset.t()}
  def update(id, params) do
    with {:ok, struct} <- fetch(id) do
      struct
      |> @schema.changeset(params)
      |> Repo.update()
    end
  end
end
