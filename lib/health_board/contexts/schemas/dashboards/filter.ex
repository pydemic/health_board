defmodule HealthBoard.Contexts.Dashboards.Filter do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "filters" do
    field :sid, :string, null: false

    field :name, :string, null: false
    field :description, :string

    field :default, :string

    field :disabled, :boolean, default: false

    field :options_module, :string, null: false
    field :options_function, :string, null: false
    field :options_params, :string

    has_many :elements, Dashboards.ElementFilter
  end
end
