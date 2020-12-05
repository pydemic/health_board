defmodule HealthBoard.Contexts.Info.SectionCard do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "sections_cards" do
    field :name, :string

    field :link, :boolean

    belongs_to :section, Info.Section, type: :string
    belongs_to :card, Info.Card, type: :string

    has_many :filters, Info.SectionCardFilter
  end
end
