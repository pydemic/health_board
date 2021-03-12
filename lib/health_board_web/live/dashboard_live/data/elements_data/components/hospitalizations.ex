defmodule HealthBoardWeb.DashboardLive.ElementsData.Components.Hospitalizations do
  alias HealthBoardWeb.DashboardLive.ElementsData.Components

  @label "Internações"

  @scalar_param "hospitalizations"

  @daily_param "daily_#{@scalar_param}"

  @per_age_gender_param "#{@scalar_param}_per_age_gender"
  @per_comorbidity_param "#{@scalar_param}_per_comorbidity"
  @per_location_param "#{@scalar_param}_per_location"
  @per_race_param "#{@scalar_param}_per_race"
  @per_symptom_param "#{@scalar_param}_per_symptom"

  @spec daily_epicurve(map, map) :: {:ok, tuple} | :error
  def daily_epicurve(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @daily_param) do
      Components.daily_epicurve(list, @label)
    end
  end

  @spec per_age_gender(map, map) :: {:ok, tuple} | :error
  def per_age_gender(data, params) do
    case Components.fetch_data(data, params, @per_age_gender_param) do
      {:ok, %{values: list}} -> Components.per_age_gender(list)
      _result -> :error
    end
  end

  @spec per_comorbidity(map, map) :: {:ok, tuple} | :error
  def per_comorbidity(data, params) do
    case Components.fetch_data(data, params, @per_comorbidity_param) do
      {:ok, %{values: list}} -> Components.per_comorbidity(list, @label)
      _result -> :error
    end
  end

  @spec per_race(map, map) :: {:ok, tuple} | :error
  def per_race(data, params) do
    case Components.fetch_data(data, params, @per_race_param) do
      {:ok, %{values: list}} -> Components.per_race(list, @label)
      _result -> :error
    end
  end

  @spec per_symptom(map, map) :: {:ok, tuple} | :error
  def per_symptom(data, params) do
    case Components.fetch_data(data, params, @per_symptom_param) do
      {:ok, %{values: list}} -> Components.per_symptom(list, @label)
      _result -> :error
    end
  end

  @spec scalar(map, map) :: {:ok, tuple} | :error
  def scalar(data, params) do
    case Components.fetch_data(data, params, @scalar_param) do
      {:ok, %{total: total}} -> Components.scalar(total)
      _result -> :error
    end
  end

  @spec top_ten_locations_table(map, map) :: {:ok, tuple} | :error
  def top_ten_locations_table(data, params) do
    with {:ok, list} <- Components.fetch_data(data, params, @per_location_param) do
      Components.top_ten_locations_table(list)
    end
  end
end
