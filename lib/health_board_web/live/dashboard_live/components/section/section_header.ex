defmodule HealthBoardWeb.DashboardLive.Components.SectionHeader do
  use Surface.Component

  alias Phoenix.LiveView

  @doc "Additional class"
  prop class, :string

  @doc "The section title"
  prop title, :string, required: true

  @doc "The section description"
  prop description, :string

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h2 class="uk-heading-line uk-text-center">
      <span uk-tooltip={{ @description }}>
        {{ @title }}
      </span>
    </h2>
    """
  end
end
