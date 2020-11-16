defmodule HealthBoard.Contexts.Info.Format do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info.Format

  @primary_key {:id, :string, autogenerate: false}
  schema "formats" do
    field :name, :string
    field :description, :string
  end

  @spec changeset(%Format{}, map()) :: Ecto.Changeset.t()
  def changeset(format, attrs) do
    format
    |> cast(attrs, [:id, :name, :description])
    |> validate_required([:id, :name, :description])
    |> unique_constraint([:id])
  end
end
