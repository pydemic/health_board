defmodule HealthBoard.Contexts.Geo.Location do
  use Ecto.Schema

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "locations" do
    field :context, :integer

    field :name, :string
    field :abbr, :string

    belongs_to :parent, __MODULE__

    has_many :children, __MODULE__, foreign_key: :parent_id
  end
end
