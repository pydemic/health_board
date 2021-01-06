defmodule HealthBoard.Contexts.SituationReport.WeekCOVIDReports do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "weekly_covid_reports" do
    field :year, :integer, null: false
    field :week, :integer, null: false

    field :cases, :integer, default: 0
    field :deaths, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
