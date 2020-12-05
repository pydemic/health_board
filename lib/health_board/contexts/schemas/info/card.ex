defmodule HealthBoard.Contexts.Info.Card do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "cards" do
    field :name, :string
    field :description, :string

    belongs_to :indicator, Info.Indicator, type: :string
  end
end
