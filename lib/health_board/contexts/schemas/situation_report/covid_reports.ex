defmodule HealthBoard.Contexts.SituationReport.COVIDReports do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo

  schema "pandemic_covid_reports" do
    field :cases, :integer, default: 0
    field :deaths, :integer, default: 0

    belongs_to :location, Geo.Location
  end
end
