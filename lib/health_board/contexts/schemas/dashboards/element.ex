defmodule HealthBoard.Contexts.Dashboards.Element do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  schema "elements" do
    field :type, :integer, null: false

    field :name, :string, null: false
    field :description, :string

    field :component_module, :string, null: false
    field :component_function, :string, null: false
    field :component_params, :string

    has_one :link_element, __MODULE__
    has_one :parent, Dashboards.ElementChild, foreign_key: :child_id

    has_many :children, Dashboards.ElementChild, foreign_key: :parent_id
    has_many :data, Dashboards.ElementData
    has_many :filters, Dashboards.ElementFilter
    has_many :indicators, Dashboards.ElementIndicator
    has_many :sources, Dashboards.ElementSource
  end
end
