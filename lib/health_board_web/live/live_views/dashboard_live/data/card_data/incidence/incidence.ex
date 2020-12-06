defmodule HealthBoardWeb.DashboardLive.CardData.Incidence do
  @spec fetch(map()) :: map()
  def fetch(%{data: data, filters: filters} = card_data) do
    %{}
    |> fetch_year_morbidity(data, filters)
    |> fetch_year_deaths(data, filters)
    |> select_color()
    |> fetch_dates(data)
    |> update(card_data)
  end

  defp fetch_year_morbidity(view_data, %{yearly_morbidities: morbidities}, filters) do
    Map.put(view_data, :year_morbidity, fetch_from_yearly_cases(morbidities, filters))
  end

  defp fetch_year_morbidity(view_data, _data, _filters) do
    Map.put(view_data, :year_morbidity, %{total: 0, average: 0, color: nil})
  end

  defp fetch_year_deaths(view_data, %{yearly_deaths: deaths}, filters) when is_list(deaths) do
    Map.put(view_data, :year_deaths, fetch_from_yearly_cases(deaths, filters))
  end

  defp fetch_year_deaths(view_data, _data, _filters) do
    Map.put(view_data, :year_deaths, %{total: 0, average: 0, color: nil})
  end

  defp fetch_from_yearly_cases(yearly_cases, %{"morbidity_context" => context}) when is_list(yearly_cases) do
    yearly_context_cases = Enum.filter(yearly_cases, &(&1.context == context))
    years = Enum.count(yearly_context_cases)

    {total, average} =
      if years == 0 do
        {0, 0}
      else
        # year = Date.utc_today().year
        year = 2019
        total = Enum.find_value(yearly_context_cases, 0, &if(&1.year == year, do: &1.total))
        average = div(Enum.sum(Enum.map(yearly_context_cases, & &1.total)), years)
        {total, average}
      end

    color =
      cond do
        total == 0 -> nil
        average > total -> :success
        average == total -> :warning
        true -> :danger
      end

    %{total: total, average: average, color: color}
  end

  defp fetch_from_yearly_cases(_view_data, _filters) do
    %{}
  end

  defp select_color(%{year_morbidity: %{color: morbidity_color}, year_deaths: %{color: deaths_color}} = view_data) do
    colors = [morbidity_color, deaths_color]

    cond do
      :danger in colors -> Map.put(view_data, :color, :danger)
      :warning in colors -> Map.put(view_data, :color, :warning)
      :success in colors -> Map.put(view_data, :color, :success)
      true -> view_data
    end
  end

  defp select_color(view_data) do
    view_data
  end

  defp fetch_dates(view_data, _data) do
    Map.merge(view_data, %{extraction_date: Date.utc_today(), last_case_date: Date.utc_today()})
  end

  defp update(data, key \\ :view_data, section_data) do
    Map.put(section_data, key, data)
  end
end
