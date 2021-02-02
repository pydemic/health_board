defmodule HealthBoard.Contexts.Dashboards.ElementChild do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  schema "elements_children" do
    belongs_to :parent, Dashboards.Element
    belongs_to :child, Dashboards.Element
  end
end
