defmodule HealthBoard.Contexts.Info.IndicatorChild do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  schema "indicators_children" do
    belongs_to :indicator, Info.Indicator, type: :string
    belongs_to :child, Info.Indicator, type: :string
  end
end
