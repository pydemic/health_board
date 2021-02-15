defmodule HealthBoardWeb.DashboardLive.Components.Dashboard do
  use Surface.Component
  alias __MODULE__.{Footer, Group, Header, Modals}
  alias HealthBoardWeb.DashboardLive.Components.DataWrapper
  alias Phoenix.LiveView

  prop dashboard, :map, required: true
  prop params, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @dashboard.id }} :let={{ data: _data }}>
      <Header name={{ @dashboard.name }} groups={{ @dashboard.children }} group_index={{ @dashboard.group_index }} />

      <Group group={{ Enum.at(@dashboard.children, @dashboard.group_index) }} />

      <Footer
        name={{ @dashboard.name }}
        organizations={{ @dashboard.organizations }}
        other_dashboards={{ @dashboard.other_dashboards }}
        version={{ @dashboard.version }}
      />

      <Modals id={{ :modals }} params={{ @dashboard.params }} />
    </DataWrapper>
    """
  end
end
