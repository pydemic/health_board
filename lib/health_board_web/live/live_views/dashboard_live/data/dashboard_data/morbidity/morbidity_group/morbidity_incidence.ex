defmodule HealthBoardWeb.DashboardLive.SectionData.MorbidityIncidence do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :year,
    :from_year,
    :to_year,
    :from_week,
    :to_week,
    :year_locations_morbidity,
    :year_locations_population,
    :yearly_morbidity,
    :weekly_morbidity,
    :yearly_population,
    :year_morbidity,
    :locations_ids,
    :location_id,
    :morbidity_context
  ]

  @data_keys [
    :year,
    :from_year,
    :to_year,
    :from_week,
    :to_week,
    :morbidity_data_period,
    :year_locations_morbidity,
    :year_locations_population,
    :yearly_morbidity,
    :weekly_morbidity,
    :yearly_population,
    :year_morbidity,
    :location,
    :locations,
    :location_name,
    :locations_names,
    :morbidity_name
  ]

  @spec fetch(pid, map, map) :: nil
  def fetch(pid, section, %{changed_filters: changes} = data) do
    if DataManager.filters_changed?(changes, @changes_keys) do
      data = Map.take(data, @data_keys)
      Enum.each(section.cards, &CardData.request_to_fetch(pid, &1, data))
    end

    nil
  end
end
