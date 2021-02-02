defmodule HealthBoard.Contexts.Consolidations.WeekLocationConsolidation do
  use Ecto.Schema
  alias HealthBoard.Contexts.{Consolidations, Geo}

  @type schema :: %__MODULE__{}

  schema "weekly_locations_consolidations" do
    field :year, :integer, null: false
    field :week, :integer, null: false

    field :total, :integer
    field :values, :string

    belongs_to :consolidation_group, Consolidations.ConsolidationGroup
    belongs_to :location, Geo.Location
  end
end
