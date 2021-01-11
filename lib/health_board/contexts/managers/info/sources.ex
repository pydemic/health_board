defmodule HealthBoard.Contexts.Info.Sources do
  alias HealthBoard.Contexts.Info.Source
  alias HealthBoard.Repo

  @type schema :: %Source{}

  @schema Source

  @spec get(String.t()) :: {:ok, schema} | {:error, :not_found}
  def get(id) do
    case Repo.get(@schema, id) do
      nil -> {:error, :not_found}
      struct -> {:ok, struct}
    end
  end

  @spec update(String.t(), map) :: {:ok, schema} | {:error, Ecto.Changeset.t()}
  def update(id, params) do
    with {:ok, struct} <- get(id) do
      struct
      |> @schema.changeset(params)
      |> Repo.update()
    end
  end
end
