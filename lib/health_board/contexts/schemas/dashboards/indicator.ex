defmodule HealthBoard.Contexts.Dashboards.Indicator do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "indicators" do
    field :sid, :string, null: false

    field :name, :string, null: false
    field :description, :string, null: false

    field :formula, :string, null: false
    field :measurement_unit, :string

    field :link, :string

    has_many :elements, Dashboards.ElementIndicator
  end
end
