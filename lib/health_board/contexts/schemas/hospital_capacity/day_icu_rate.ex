defmodule HealthBoard.Contexts.HospitalCapacity.DayICURate do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "daily_icu_rate" do
    field :date, :date, null: false

    field :rate, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
