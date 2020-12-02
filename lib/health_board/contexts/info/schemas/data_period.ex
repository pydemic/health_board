defmodule HealthBoard.Contexts.Info.DataPeriod do
  use Ecto.Schema
  alias HealthBoard.Contexts.Geo
  alias HealthBoard.Contexts.Info.DataPeriod

  @schema DataPeriod

  @type schema :: %DataPeriod{}

  schema "data_periods" do
    field :context, :integer, null: false

    field :from_date, :date, null: false
    field :to_date, :date, null: false

    field :extraction_date, :date, null: false

    belongs_to :location, Geo.Location

    field :from_year, :integer, virtual: true
    field :to_year, :integer, virtual: true

    field :from_week, :integer, virtual: true
    field :to_week, :integer, virtual: true
  end

  @spec fetch_years(schema()) :: schema()
  def fetch_years(%{from_date: %{year: from_year}, to_date: %{year: to_year}} = struct) do
    %@schema{struct | from_year: from_year, to_year: to_year}
  end

  @spec fetch_weeks(schema()) :: schema()
  def fetch_weeks(%{from_date: from_date, to_date: to_date} = struct) do
    {_year, from_week} = :calendar.iso_week_number(Date.to_erl(from_date))
    {_year, to_week} = :calendar.iso_week_number(Date.to_erl(to_date))

    %@schema{struct | from_week: from_week, to_week: to_week}
  end
end
