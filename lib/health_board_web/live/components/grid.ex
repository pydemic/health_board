defmodule HealthBoardWeb.LiveComponents.Grid do
  use Surface.Component

  alias Phoenix.LiveView

  @doc "Additional class"
  prop class, :string

  @doc "Enable it to add horizontal margin"
  prop horizontal_margin, :boolean, default: false

  @doc "Wrap it into a div. Use it when using grid inside grids"
  prop wrap, :boolean, default: false

  @doc "The width of the grid on large screens. Works only on wrapped grids"
  prop width_l, :integer

  @doc "The width of the grid on average-size screens. Works only on wrapped grids"
  prop width_m, :integer

  @doc "Define a matching class to align children according to the div with the class"
  prop matching_class, :string

  @doc "The section content"
  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    if assigns[:wrap] do
      ~H"""
      <div class={{
        "uk-width-1-#{@width_l}@l": @width_l,
        "uk-width-1-#{@width_m}@m": @width_m
      }}>
        {{ do_render(assigns) }}
      </div>
      """
    else
      do_render(assigns)
    end
  end

  defp do_render(assigns) do
    ~H"""
    <div
      class={{
        "uk-grid",
        "uk-flex-center",
        "uk-grid-small",
        "uk-grid-match",
        "uk-text-center",
        "uk-animation-fade",
        "uk-margin-left": @horizontal_margin,
        "uk-margin-right": @horizontal_margin,
        "#{@class}": @class
      }}
      uk-height-match={{ @matching_class }}
      uk-grid
    >
      <slot/>
    </div>
    """
  end
end
