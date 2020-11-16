defmodule HealthBoard.Contexts.Morbidities.YearlyMortalitiesCases do
  import Ecto.Query, only: [order_by: 2, where: 2, dynamic: 1, dynamic: 2]
  alias HealthBoard.Contexts.Morbidities.YearMortalityCases
  alias HealthBoard.Repo

  @type schema :: %YearMortalityCases{}

  @schema YearMortalityCases

  @spec new :: schema()
  def new, do: %@schema{}

  @spec get_by!(keyword()) :: schema()
  def get_by!(params) do
    @schema
    |> where(^filter_where(params))
    |> Repo.one!()
  end

  @spec list_by(keyword()) :: list(schema())
  def list_by(params) do
    @schema
    |> where(^filter_where(params))
    |> order_by(^Keyword.get(params, :order_by, asc: :location_id))
    |> Repo.all()
  end

  @spec general_disease_context :: integer()
  def general_disease_context, do: 0

  @spec dengue_disease_context :: integer()
  def dengue_disease_context, do: 1

  @spec chikungunya_disease_context :: integer()
  def chikungunya_disease_context, do: 2

  @spec zika_disease_context :: integer()
  def zika_disease_context, do: 3

  @spec domestic_violence_disease_context :: integer()
  def domestic_violence_disease_context, do: 4

  @spec sexual_violence_disease_context :: integer()
  def sexual_violence_disease_context, do: 5

  @spec suicide_disease_context :: integer()
  def suicide_disease_context, do: 6

  @spec resident_location_context :: integer()
  def resident_location_context, do: 0

  @spec source_location_context :: integer()
  def source_location_context, do: 1

  defp filter_where(params) do
    Enum.reduce(params, dynamic(true), fn
      {:disease_context, context}, dynamic -> dynamic([row], ^dynamic and row.disease_context == ^context)
      {:location_context, context}, dynamic -> dynamic([row], ^dynamic and row.location_context == ^context)
      {:location_id, id}, dynamic -> dynamic([row], ^dynamic and row.location_id == ^id)
      {:locations_ids, ids}, dynamic -> dynamic([row], ^dynamic and row.location_id in ^ids)
      {:year, year}, dynamic -> dynamic([row], ^dynamic and row.year == ^year)
      {:year_period, [from, to]}, dynamic -> dynamic([row], ^dynamic and row.year >= ^from and row.year <= ^to)
      _param, dynamic -> dynamic
    end)
  end
end
