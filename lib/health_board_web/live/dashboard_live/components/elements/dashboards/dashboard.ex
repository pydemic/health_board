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
    <DataWrapper id={{ @dashboard.id }} :let={{ data: _data }} wrapper_class="flex flex-col min-h-screen">
      <Header id={{ :header }} dashboard={{ @dashboard }} />

      <Group group={{ Enum.at(@dashboard.children, @dashboard.group_index) }} />

      <Footer
        dark_mode={{ @dashboard.dark_mode }}
        name={{ @dashboard.name }}
        organizations={{ @dashboard.organizations }}
        params={{ @dashboard.params }}
        version={{ @dashboard.version }}
      />

      <Modals id={{ :modals }} params={{ @dashboard.params }} />
    </DataWrapper>
    """
  end
end
