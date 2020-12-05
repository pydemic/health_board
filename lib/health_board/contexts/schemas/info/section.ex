defmodule HealthBoard.Contexts.Info.Section do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "sections" do
    field :name, :string
    field :description, :string

    has_many :cards, Info.SectionCard
  end
end
