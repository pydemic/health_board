defmodule HealthBoard.Contexts.Dashboards.Sources do
  alias HealthBoard.Contexts.Dashboards.Source
  alias HealthBoard.Repo

  @type schema :: %Source{}

  @schema Source

  @spec fetch(integer) :: {:ok, schema} | :error
  def fetch(id) do
    case Repo.get(@schema, id) do
      nil -> :error
      struct -> {:ok, struct}
    end
  end

  @spec fetch_by_sid(String.t()) :: {:ok, schema} | :error
  def fetch_by_sid(sid) do
    case Repo.get_by(@schema, sid: sid) do
      nil -> :error
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
