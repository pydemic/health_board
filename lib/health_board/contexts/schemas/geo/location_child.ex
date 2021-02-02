defmodule HealthBoard.Contexts.Geo.LocationChild do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "locations_children" do
    field :parent_group, :integer
    field :child_group, :integer

    belongs_to :parent, Geo.Location
    belongs_to :child, Geo.Location
  end
end
