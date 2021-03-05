defmodule HealthBoard.Contexts.Consolidations.ConsolidationGroup do
  use Ecto.Schema
  alias HealthBoard.Contexts.Consolidations

  @type schema :: %__MODULE__{}

  @derive {Jason.Encoder, only: [:name]}
  schema "consolidations_groups" do
    field :name, :string, null: false

    has_many :locations_consolidations, Consolidations.LocationConsolidation
    has_many :yearly_locations_consolidations, Consolidations.YearLocationConsolidation
    has_many :monthly_locations_consolidations, Consolidations.MonthLocationConsolidation
    has_many :weekly_locations_consolidations, Consolidations.WeekLocationConsolidation
    has_many :daily_locations_consolidations, Consolidations.DayLocationConsolidation
  end
end
