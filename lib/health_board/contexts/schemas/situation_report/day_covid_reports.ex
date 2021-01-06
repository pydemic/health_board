defmodule HealthBoard.Contexts.SituationReport.DayCOVIDReports do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "daily_covid_reports" do
    field :date, :date, null: false

    field :cases, :integer, default: 0
    field :deaths, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
