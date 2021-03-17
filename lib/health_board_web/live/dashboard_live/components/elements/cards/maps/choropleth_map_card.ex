defmodule HealthBoardWeb.DashboardLive.Components.ChoroplethMapCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.BasicMapCard
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
        <Otherwise condition={{ Map.has_key?(data, :error?) == false }} >
          <BasicMapCard id={{ "element_#{@card.id}_map" }} map_data={{ data }} element={{ @card }} params={{ @params }} />

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
end
