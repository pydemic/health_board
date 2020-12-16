defmodule HealthBoardWeb.DashboardLive.SectionData.DemographicBirths do
  alias HealthBoardWeb.DashboardLive.{CardData, DataManager}

  @changes_keys [
    :year,
    :from_year,
    :to_year,
    :year_locations_population,
    :yearly_population,
    :year_population,
    :year_locations_births,
    :yearly_births,
    :year_births,
    :locations_ids,
    :location_id
  ]

  @data_keys [
    :births_year,
    :births_from_year,
    :births_to_year,
    :year_locations_population,
    :yearly_population,
    :year_population,
    :year_locations_births,
    :yearly_births,
    :location,
    :locations,
    :location_name,
    :locations_names,
    :year_births
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
