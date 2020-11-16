defmodule HealthBoardWeb.DashboardLive.GridComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView

  @default_class [
    "uk-grid",
    "uk-flex-center",
    "uk-grid-small",
    "uk-grid-match",
    "uk-text-center",
    "uk-animation-fade"
  ]

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    options = assigns[:options] || []

    case options[:wrap] do
      true -> wrap(assigns, options)
      _wrap -> grid(assigns, options)
    end
  end

  defp wrap(assigns, options) do
    ~L"""
    <div class="<%= wrap_class options %>">
      <%= grid(assigns, options) %>
    </div>
    """
  end

  defp wrap_class(options) do
    []
    |> maybe_add_width(options[:width_l], "l")
    |> maybe_add_width(options[:width_m], "m")
    |> Enum.join(" ")
  end

  defp maybe_add_width(class, nil, _scale), do: class
  defp maybe_add_width(class, value, scale), do: ["uk-width-1-#{value}@#{scale}"] ++ class

  defp grid(assigns, options) do
    match = options[:match] || ".hb_match"

    ~L"""
    <div
      class="<%= grid_class options %>"
      uk-height-match="<%= match %>""
      uk-grid
    >
      <%= @inner_content.(assigns) %>
    </div>
    """
  end

  defp grid_class(options) do
    case options[:matcher] do
      nil -> @default_class
      matcher -> [matcher] ++ @default_class
    end
    |> maybe_add_margin(options[:no_margin])
    |> Enum.join(" ")
  end

  defp maybe_add_margin(class, true), do: class
  defp maybe_add_margin(class, _no_margin), do: ["uk-margin-left", "uk-margin-right"] ++ class
end
