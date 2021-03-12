defmodule HealthBoard.Contexts.Dashboards.ElementSource do
  use Ecto.Schema
  alias HealthBoard.Contexts.Dashboards

  @type schema :: %__MODULE__{}

  @primary_key {:id, :integer, autogenerate: false}
  schema "elements_sources" do
    belongs_to :element, Dashboards.Element
    belongs_to :source, Dashboards.Source
  end
end
