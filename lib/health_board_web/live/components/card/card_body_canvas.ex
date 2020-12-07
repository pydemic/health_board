defmodule HealthBoardWeb.LiveComponents.CardBodyCanvas do
  use Surface.Component, slot: "body"

  alias Phoenix.LiveView

  @doc "Additional class"
  prop class, :string

  @doc "The canvas id"
  prop id, :string, required: true

  @doc "Canvas minimum height"
  prop height, :integer, default: 400

  @doc "The hook name for phx-hook"
  prop hook, :string, default: "Chart"

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-card-body", "#{@class}": @class }} style={{ "min-height: #{@height};" }}>
      <canvas id={{ @id }} height={{ @height }} phx-hook={{ @hook }}></canvas>
    </div>
    """
  end
end
