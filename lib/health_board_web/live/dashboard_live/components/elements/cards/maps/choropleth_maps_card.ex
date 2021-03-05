defmodule HealthBoardWeb.DashboardLive.Components.ChoroplethMapsCard do
  use Surface.Component
  alias __MODULE__.MapCard
  alias HealthBoardWeb.DashboardLive.Components.{BasicCard, DataWrapper}
  alias HealthBoardWeb.DashboardLive.Components.Fragments.{Loading, NA, Otherwise}
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  data show_regions, :boolean, default: false

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @card.id }} :let={{ data: data }}>
      <Otherwise condition={{ Enum.any?(data) }}>
        <Otherwise condition={{ Map.has_key?(data, :error?) == false }} extra_true_class={{ "grid place-items-stretch gap-4", grid_cols(data[:length]) }} >
          <MapCard :if={{ Map.has_key?(data, :regions_data) }} id={{ "element_#{@card.id}_regions" }} map_data={{ data.regions_data }} element={{ Map.put(@card, :name, "#{@card.name} - Regiões") }} params={{ @params }} />
          <MapCard :if={{ Map.has_key?(data, :states_data) }} id={{ "element_#{@card.id}_states" }} map_data={{ data.states_data }} element={{ Map.put(@card, :name, "#{@card.name} - Estados") }} params={{ @params }} />
          <MapCard :if={{ Map.has_key?(data, :health_regions_data) }} id={{ "element_#{@card.id}_health_regions" }} map_data={{ data.health_regions_data }} element={{ Map.put(@card, :name, "#{@card.name} - Regionais de Saúde") }} params={{ @params }} />
          <MapCard :if={{ Map.has_key?(data, :cities_data) }} id={{ "element_#{@card.id}_cities" }} map_data={{ data.cities_data }} element={{ Map.put(@card, :name, "#{@card.name} - Municípios") }} params={{ @params }} />

          <template slot="otherwise">
            <BasicCard name={{ @card.name }} extra_body_class="px-5 py-2">
              <NA />
            </BasicCard>
          </template>
        </Otherwise>

        <template slot="otherwise">
          <BasicCard name={{ @card.name }} extra_body_class="px-5 py-2">
            <Loading />
          </BasicCard>
        </template>
      </Otherwise>
    </DataWrapper>
    """
  end

  defp grid_cols(length) do
    if not is_nil(length) and length > 1 do
      "lg:grid-cols-2 2xl:grid-cols-3"
    else
      nil
    end
  end
end
