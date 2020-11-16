defmodule HealthBoard.Contexts.Geo.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias HealthBoard.Contexts.Geo.Location

  @primary_key {:id, :integer, autogenerate: false}
  schema "locations" do
    field :level, :integer

    field :name, :string
    field :abbr, :string

    belongs_to :parent, Location

    has_many :children, Location, foreign_key: :parent_id
  end

  @doc false
  @spec changeset(%Location{}, map()) :: Ecto.Changeset.t()
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:id, :level, :name, :abbr, :parent_id])
    |> validate_required([:id, :level, :name])
    |> unique_constraint([:level, :id])
  end
end
