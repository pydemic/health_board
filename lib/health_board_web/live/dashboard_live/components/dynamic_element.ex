defmodule HealthBoardWeb.DashboardLive.Components.DynamicElement do
  use Surface.Component

  alias Phoenix.LiveView

  prop element, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(%{element: element} = assigns) do
    %{component_module: module, component_function: function, component_params: params} = element

    HealthBoardWeb.DashboardLive.Components
    |> Module.concat(module)
    |> apply(String.to_atom(function), [assigns, URI.decode_query(params || "")])
  end
end
