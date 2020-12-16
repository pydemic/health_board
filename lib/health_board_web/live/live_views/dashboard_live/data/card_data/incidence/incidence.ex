defmodule HealthBoardWeb.DashboardLive.CardData.Incidence do
  alias HealthBoard.Contexts

  @empty_data %{total: 0, average: 0, severity: nil, first_record_date: nil, last_record_date: nil}

  @spec fetch(pid, map, map) :: map
  def fetch(_pid, _card, data) do
    if data.section_card_id != "morbidity_incidence" do
      {%{}, data}
      |> fetch_morbidity()
      |> fetch_deaths()
      |> select_severity()
      |> fetch_result()
    else
      %{
        filters: %{
          year: data.year,
          location: data.location_name,
          morbidity_context: data.morbidity_name
        },
        result: %{cases: data.year_morbidity.total}
      }
    end
  end

  defp fetch_morbidity({result, %{yearly_morbidities_per_context: cases_per_context} = data}) do
    cases = Map.get(cases_per_context, data.morbidity_context, [])
    result = Map.put(result, :morbidity, fetch_cases(cases, data, fetch_data_period(data, :morbidity)))
    {result, data}
  end

  defp fetch_morbidity({result, %{yearly_morbidity: cases} = data}) do
    result = Map.put(result, :morbidity, fetch_cases(cases, data, fetch_data_period(data, :morbidity)))
    {result, data}
  end

  defp fetch_morbidity({result, data}) do
    result = Map.put(result, :morbidity, @empty_data)
    {result, data}
  end

  defp fetch_deaths({result, %{yearly_deaths_per_context: cases_per_context} = data}) do
    cases = Map.get(cases_per_context, data.morbidity_context, [])
    result = Map.put(result, :deaths, fetch_cases(cases, data, fetch_data_period(data, :deaths)))
    {result, data}
  end

  defp fetch_deaths({result, %{yearly_deaths: cases} = data}) do
    result = Map.put(result, :deaths, fetch_cases(cases, data, fetch_data_period(data, :deaths)))
    {result, data}
  end

  defp fetch_deaths({result, data}) do
    result = Map.put(result, :deaths, @empty_data)
    {result, data}
  end

  defp fetch_cases(cases, %{year: year}, data_period) do
    years = Enum.count(cases)

    {total, average} =
      if years == 0 do
        {0, 0}
      else
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

  defp select_severity({result, data}) do
    %{morbidity: %{severity: morbidity_severity}, deaths: %{severity: deaths_severity}} = result

    severities = [morbidity_severity, deaths_severity]

    severity =
      cond do
        :above_average in severities -> :above_average
        :on_average in severities -> :on_average
        :below_average in severities -> :below_average
        true -> nil
      end

    result = Map.put(result, :overall_severity, severity)

    {result, data}
  end

  defp fetch_result({result, data}) do
    %{year: year, morbidity_context: morbidity_context} = data

    %{
      filters: %{
        year: year,
        location: data.location_name,
        morbidity_context: Contexts.morbidity_name(data.morbidity_context)
      },
      border_color: severity_to_color(result.overall_severity),
      params: Map.put(data.params, :morbidity_context, morbidity_context),
      result: result
    }
  end

  defp severity_to_color(:below_average), do: :success
  defp severity_to_color(:on_average), do: :warning
  defp severity_to_color(:above_average), do: :danger
  defp severity_to_color(nil), do: nil
end
