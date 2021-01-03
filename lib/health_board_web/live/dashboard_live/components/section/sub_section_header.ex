defmodule HealthBoardWeb.DashboardLive.Components.SubSectionHeader do
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
    <h3 class="uk-heading-bullet">
      <span uk-tooltip={{ @description }}>
        {{ @title }}
      </span>
    </h3>
    """
  end
end
