defmodule HealthBoardWeb.DashboardLive.ElementsFiltersData.Time do
  @spec date(map) :: map
  def date(_params) do
    %{name: "date", value: Date.utc_today(), verbose_value: "20/04/2020"}
  end

  @spec date_period(map) :: map
  def date_period(_params) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    %{name: "date_period", value: %{from: yesterday, to: today}, verbose_value: "19/04/2020 ~ 20/04/2020"}
  end

  @spec period(map) :: map
  def period(_params) do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)
    %{name: "period", value: %{type: :daily, from: yesterday, to: today}, verbose_value: "19/04/2020 ~ 20/04/2020"}
  end
end
