defmodule HealthBoard.Contexts.Info.Indicator do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "indicators" do
    field :description, :string
    field :formula, :string
    field :measurement_unit, :string
    field :reference, :string

    has_many :children, Info.IndicatorChild
    has_many :sources, Info.IndicatorSource
  end
end
