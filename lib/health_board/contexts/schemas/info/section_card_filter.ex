defmodule HealthBoard.Contexts.Info.SectionCardFilter do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  schema "sections_cards_filters" do
    field :filter, :string
    field :value, :string

    belongs_to :section_card, Info.SectionCard, type: :string
  end
end
