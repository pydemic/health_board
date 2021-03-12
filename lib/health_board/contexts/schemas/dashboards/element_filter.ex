defmodule HealthBoard.Contexts.Dashboards.ElementFilter do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "elements_filters" do
    field :name, :string
    field :description, :string

    field :default, :string

    field :disabled, :boolean

    field :options_module, :string
    field :options_function, :string
    field :options_params, :string

    belongs_to :element, Dashboards.Element
    belongs_to :filter, Dashboards.Filter
  end
end
