defmodule HealthBoard.Contexts.Info.DataPeriod do
  use Ecto.Schema
  alias HealthBoard.Contexts.Info.DataPeriod
  alias HealthBoard.Contexts.Geo

  @schema DataPeriod

  @type schema :: %DataPeriod{}

  schema "data_periods" do
    field :context, :integer, null: false

    field :from_date, :date, null: false
    field :to_date, :date, null: false

    field :extraction_date, :date, null: false

    belongs_to :location, Geo.Location

    field :from_year, :date, virtual: true
    field :to_year, :date, virtual: true

    field :from_week, :date, virtual: true
    field :to_week, :date, virtual: true
  end

  @spec fetch_years(schema()) :: schema()
  def fetch_years(%{from_date: %{year: from_year}, to_date: %{year: to_year}} = struct) do
    %@schema{struct | from_year: from_year, to_year: to_year}
  end
end
