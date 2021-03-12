defmodule HealthBoard.Contexts.Dashboards.ElementData do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "elements_data" do
    field :field, :string, null: false

    field :data_module, :string, null: false
    field :data_function, :string, null: false
    field :data_params, :string

    belongs_to :element, Dashboards.Element
  end
end
