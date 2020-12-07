defmodule HealthBoardWeb.DashboardLive.CardData.Incidence do
  alias HealthBoard.Contexts

  @empty_data %{total: 0, average: 0, severity: nil, first_record_date: nil, last_record_date: nil}

  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = card_data) do
    %{}
    |> fetch_year_morbidity(data, filters)
    |> fetch_year_deaths(data, filters)
    |> select_severity()
    |> update(card_data)
    |> Map.put(:filters, Map.update!(filters, :morbidity_context, &Contexts.morbidity_name(&1)))
  end

  defp fetch_year_morbidity(view_data, %{yearly_morbidities: morbidities} = data, filters) do
    data_periods = Map.fetch!(data.data_periods, Contexts.data_context!(:morbidity))
    Map.put(view_data, :year_morbidity, fetch_from_yearly_cases(morbidities, filters, data_periods))
  end

  defp fetch_year_morbidity(view_data, _data, _filters) do
    Map.put(view_data, :year_morbidity, @empty_data)
  end

  defp fetch_year_deaths(view_data, %{yearly_deaths: deaths} = data, filters) do
    data_periods = Map.fetch!(data.data_periods, Contexts.data_context!(:deaths))
    Map.put(view_data, :year_deaths, fetch_from_yearly_cases(deaths, filters, data_periods))
  end

  defp fetch_year_deaths(view_data, _data, _filters) do
    Map.put(view_data, :year_deaths, @empty_data)
  end

  defp fetch_from_yearly_cases(yearly_cases, filters, data_periods) do
    context = filters.morbidity_context

    yearly_context_cases = Enum.filter(yearly_cases, &(&1.context == context))
    years = Enum.count(yearly_context_cases)

    {total, average} =
      if years == 0 do
        {0, 0}
      else
        year = Map.get_lazy(filters, :year, fn -> Date.utc_today().year end)
        total = Enum.find_value(yearly_context_cases, 0, &if(&1.year == year, do: &1.total))
        average = div(Enum.sum(Enum.map(yearly_context_cases, & &1.total)), years)
        {total, average}
      end

    severity =
      cond do
        total == 0 -> nil
        average > total -> :below_average
        average == total -> :on_average
        true -> :above_average
      end

    [%{from_date: from, to_date: to}] = Map.get(data_periods, context, [%{from_date: nil, to_date: nil}])

    %{total: total, average: average, severity: severity, first_record_date: from, last_record_date: to}
  end

  defp select_severity(view_data) do
    %{year_morbidity: %{severity: morbidity_severity}, year_deaths: %{severity: deaths_severity}} = view_data

    severities = [morbidity_severity, deaths_severity]

    cond do
      :above_average in severities -> Map.put(view_data, :overall_severity, :above_average)
      :on_average in severities -> Map.put(view_data, :overall_severity, :on_average)
      :below_average in severities -> Map.put(view_data, :overall_severity, :below_average)
      true -> Map.put(view_data, :overall_severity, nil)
    end
  end

  defp update(data, key \\ :view_data, section_data) do
    Map.put(section_data, key, data)
  end
end
