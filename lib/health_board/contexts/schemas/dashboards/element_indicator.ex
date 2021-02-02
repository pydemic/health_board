defmodule HealthBoard.Contexts.Dashboards.ElementIndicator do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  schema "elements_indicators" do
    belongs_to :element, Dashboards.Element
    belongs_to :indicator, Dashboards.Indicator
  end
end
