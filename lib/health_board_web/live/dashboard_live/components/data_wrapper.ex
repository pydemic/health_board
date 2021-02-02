defmodule HealthBoardWeb.DashboardLive.Components.DataWrapper do
  use Surface.LiveComponent
  alias Phoenix.LiveView

  prop wrapper_class, :css_class

  data data, :map, default: %{}

  slot default, props: [:data]

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id={{ "element_#{@id}" }} class={{ @wrapper_class }}>
      <slot :props={{ data: @data }} />
    </div>
    """
  end

  @spec fetch(pid | nil, String.t() | atom, map) :: any
  def fetch(pid \\ nil, id, data) do
    if is_nil(pid) do
      send_update(__MODULE__, id: id, data: data)
    else
      send_update(pid, __MODULE__, id: id, data: data)
    end
  end
end
