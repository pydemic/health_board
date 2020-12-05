defmodule HealthBoard.Contexts.Info.IndicatorSource do
  use Ecto.Schema

  alias HealthBoard.Contexts.Info

  @type schema :: %__MODULE__{}

  schema "indicators_sources" do
    belongs_to :indicator, Info.Indicator, type: :string
    belongs_to :source, Info.Source, type: :string
  end
end
