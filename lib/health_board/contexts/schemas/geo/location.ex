defmodule HealthBoard.Contexts.Geo.Location do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "locations" do
    field :context, :integer

    field :name, :string
    field :abbr, :string

    has_many :parents, Geo.LocationChild, foreign_key: :child_id
    has_many :children, Geo.LocationChild, foreign_key: :parent_id
  end
end
