defmodule HealthBoard.Contexts.Consolidations.DayLocationConsolidation do
  use Ecto.Schema
  alias HealthBoard.Contexts.{Consolidations, Geo}

  @type schema :: %__MODULE__{}

  schema "daily_locations_consolidations" do
    field :date, :date, null: false

    field :total, :integer
    field :values, :string

    belongs_to :consolidation_group, Consolidations.ConsolidationGroup
    belongs_to :location, Geo.Location
  end
end
