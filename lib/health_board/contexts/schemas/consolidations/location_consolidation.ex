defmodule HealthBoard.Contexts.Consolidations.LocationConsolidation do
  use Ecto.Schema
  alias HealthBoard.Contexts.{Consolidations, Geo}

  @type schema :: %__MODULE__{}

  schema "locations_consolidations" do
    field :from_date, :date
    field :to_date, :date

    field :total, :integer
    field :values, :string

    belongs_to :consolidation_group, Consolidations.ConsolidationGroup
    belongs_to :location, Geo.Location
  end
end
