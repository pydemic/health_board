defmodule HealthBoard.Contexts.ICUOccupancy.DayICUOccupancy do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "daily_covid_reports" do
    field :date, :date, null: false

    field :rate, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
