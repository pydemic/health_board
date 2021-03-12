defmodule HealthBoard.Contexts.Dashboards.Element do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "elements" do
    field :sid, :string, null: false

    field :type, :integer, null: false

    field :name, :string, null: false
    field :description, :string

    field :component_module, :string, null: false
    field :component_function, :string, null: false
    field :component_params, :string

    field :link_element_sid, :string

    has_one :parent, Dashboards.ElementChild, foreign_key: :child_id

    has_many :children, Dashboards.ElementChild, foreign_key: :parent_id
    has_many :data, Dashboards.ElementData
    has_many :filters, Dashboards.ElementFilter
    has_many :indicators, Dashboards.ElementIndicator
    has_many :sources, Dashboards.ElementSource

    field :dark_mode, :boolean, virtual: true, default: false
    field :group_index, :integer, virtual: true, default: 0
    field :organizations, :any, virtual: true, default: []
    field :other_dashboards, :any, virtual: true, default: []
    field :params, :map, virtual: true, default: %{}
    field :ranges, :any, virtual: true, default: []
    field :show_options, :boolean, virtual: true, default: true
    field :version, :string, virtual: true, default: ""
  end
end
