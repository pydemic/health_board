defmodule HealthBoardWeb.DashboardLive.Components.CardBodyText do
  use Surface.Component, slot: "body"

  alias Phoenix.LiveView

  @doc "Additional class"
  prop class, :string

  @doc "The card content if no children defined"
  prop content, :string

  slot default

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={{ "uk-card-body", "#{@class}": @class}}>
      <slot>
        <p>{{ @content }}</p>
      </slot>
    </div>
    """
  end
end
