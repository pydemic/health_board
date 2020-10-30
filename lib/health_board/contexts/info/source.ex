defmodule HealthBoard.Contexts.Info.Source do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Info
  alias HealthBoard.Contexts.Info.Source

  @primary_key {:id, :string, autogenerate: false}
  schema "sources" do
    field :name, :string
    field :description, :string
    field :link, :string

    has_many :extractions, Info.SourceExtraction
  end

  @spec changeset(%Source{}, map()) :: Ecto.Changeset.t()
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:id, :name, :description, :link])
    |> validate_required([:id, :name])
    |> unique_constraint([:id])
  end
end
