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

  @spec fetch(pid, String.t() | atom, map) :: any
  def fetch(pid \\ self(), id, data), do: send_update(pid, __MODULE__, id: id, data: data)

  @spec fetch_and_hook(pid, String.t() | atom, map, String.t(), map) :: any
  def fetch_and_hook(pid \\ self(), id, data, hook, hook_data) do
    fetch(pid, id, data)
    Process.send_after(pid, {:hook, hook, Map.put(hook_data, :id, id)}, 1_000)
  end
end
