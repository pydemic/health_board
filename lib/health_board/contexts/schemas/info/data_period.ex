defmodule HealthBoard.Contexts.Info.DataPeriod do
  use Ecto.Schema

  alias HealthBoard.Contexts.Geo

  @type schema :: %__MODULE__{}

  schema "data_periods" do
    field :data_context, :integer, null: false
    field :context, :integer, null: false

    field :from_date, :date, null: false
    field :to_date, :date, null: false

    belongs_to :location, Geo.Location

    field :from_year, :integer, virtual: true
    field :to_year, :integer, virtual: true

    field :from_week, :integer, virtual: true
    field :to_week, :integer, virtual: true
  end

  @spec fetch_years(schema) :: schema
  def fetch_years(%__MODULE__{from_date: %{year: from_year}, to_date: %{year: to_year}} = schema) do
    %__MODULE__{schema | from_year: from_year, to_year: to_year}
  end

  @spec fetch_weeks(schema) :: schema
  def fetch_weeks(%__MODULE__{from_date: from_date, to_date: to_date} = schema) do
    {from_year, from_week} = :calendar.iso_week_number(Date.to_erl(from_date))
    {to_year, to_week} = :calendar.iso_week_number(Date.to_erl(to_date))

    %__MODULE__{schema | from_week: {from_year, from_week}, to_week: {to_year, to_week}}
  end
end
