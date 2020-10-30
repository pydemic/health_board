defmodule HealthBoard.Contexts.Info.Filter do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info.Filter

  @primary_key {:id, :string, autogenerate: false}
  schema "filters" do
    field :name, :string
  end

  @spec changeset(%Filter{}, map()) :: Ecto.Changeset.t()
  def changeset(filter, attrs) do
    filter
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
    |> unique_constraint([:id])
  end
end
