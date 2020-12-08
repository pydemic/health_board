defmodule HealthBoardWeb.DashboardLive.CardData.Incidence do
  alias HealthBoard.Contexts

  @empty_data %{total: 0, average: 0, severity: nil, first_record_date: nil, last_record_date: nil}

  @spec fetch(map) :: map
  def fetch(map) do
    map
    |> fetch_morbidity_context()
    |> fetch_morbidity()
    |> fetch_deaths()
    |> select_severity()
  end

  defp fetch_morbidity_context(map) do
    if Map.has_key?(map.query_filters, :morbidity_context) and not Map.has_key?(map.data, :morbidity_context) do
      morbidity_context = map.query_filters.morbidity_context

      map
      |> put_in([:data, :morbidity_context], morbidity_context)
      |> put_in([:filters, :morbidity_context], Contexts.morbidity_name(morbidity_context))
    else
      map
    end
  end

  defp fetch_morbidity(%{data: %{yearly_morbidities_per_context: cases_per_context} = data} = map) do
    cases = Map.get(cases_per_context, data[:morbidity_context], [])
    put_in(map, [:view_data, :morbidity], fetch_cases(cases, data, fetch_data_period(data, :morbidity)))
  end

  defp fetch_morbidity(%{data: %{yearly_morbidity: cases} = data} = map) do
    put_in(map, [:view_data, :morbidity], fetch_cases(cases, data, fetch_data_period(data, :morbidity)))
  end

  defp fetch_morbidity(map) do
    put_in(map, [:view_data, :morbidity], @empty_data)
  end

  defp fetch_deaths(%{data: %{yearly_deaths_per_context: cases_per_context} = data} = map) do
    cases = Map.get(cases_per_context, data[:morbidity_context], [])
    put_in(map, [:view_data, :deaths], fetch_cases(cases, data, fetch_data_period(data, :deaths)))
  end

  defp fetch_deaths(%{data: %{yearly_deaths: cases} = data} = map) do
    put_in(map, [:view_data, :deaths], fetch_cases(cases, data, fetch_data_period(data, :deaths)))
  end

  defp fetch_deaths(map) do
    put_in(map, [:view_data, :deaths], @empty_data)
  end

  defp fetch_cases(cases, data, data_period) do
    years = Enum.count(cases)

    {total, average} =
      if years == 0 do
        {0, 0}
      else
        year = Map.get_lazy(data, :year, fn -> Date.utc_today().year end)
        total = Enum.find_value(cases, 0, &if(&1.year == year, do: &1.total))
        average = div(Enum.sum(Enum.map(cases, & &1.total)), years)
        {total, average}
      end

    severity =
      cond do
        total == 0 -> nil
        average > total -> :below_average
        average == total -> :on_average
        true -> :above_average
      end

    %{from_date: from, to_date: to} = data_period
    %{total: total, average: average, severity: severity, first_record_date: from, last_record_date: to}
  end

  defp fetch_data_period(data, data_context) do
    %{data_periods_per_context: data_periods, morbidity_context: context} = data
    data_context = Contexts.data_context!(data_context)

    data_periods
    |> Map.get(context, [])
    |> Enum.find(%{from_date: nil, to_date: nil}, &(&1.data_context == data_context))
  end

  defp select_severity(%{view_data: view_data} = map) do
    %{morbidity: %{severity: morbidity_severity}, deaths: %{severity: deaths_severity}} = view_data

    severities = [morbidity_severity, deaths_severity]

    cond do
      :above_average in severities -> put_in(map, [:view_data, :overall_severity], :above_average)
      :on_average in severities -> put_in(map, [:view_data, :overall_severity], :on_average)
      :below_average in severities -> put_in(map, [:view_data, :overall_severity], :below_average)
      true -> put_in(map, [:view_data, :overall_severity], nil)
    end
  end
end
