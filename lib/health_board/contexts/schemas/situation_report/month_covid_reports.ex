defmodule HealthBoard.Contexts.SituationReport.MonthCOVIDReports do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "monthly_covid_reports" do
    field :year, :integer, null: false
    field :month, :integer, null: false

    field :cases, :integer, default: 0
    field :deaths, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
