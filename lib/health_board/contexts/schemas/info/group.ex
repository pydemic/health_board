defmodule HealthBoard.Contexts.Info.Group do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "groups" do
    field :name, :string
    field :description, :string

    field :index, :integer

    belongs_to :dashboard, Info.Dashboard, type: :string

    has_many :sections, Info.Section
  end
end
