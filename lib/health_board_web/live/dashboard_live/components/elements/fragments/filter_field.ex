defmodule HealthBoardWeb.DashboardLive.Components.ElementsFragments.FilterField do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Dropdown
  alias Phoenix.LiveView

  prop filter, :map, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    case assigns.filter.name do
      "location" ->
        region = Enum.filter(assigns.filter.options.locations, &(&1.group == 1))
        states = Enum.filter(assigns.filter.options.locations, &(&1.group == 2))

        ~H"""
        <div>
          <div>
            <a> {{ @filter.title }}: </a>
          </div>
          <div>
            <br/> <Dropdown title="Região" data={{ region }}/>
          </div>
          <div>
            <br/> <Dropdown title="Estado" data={{ states }}/>
          </div>
        </div>
        """

      "period" ->
        ~H"""
        <a> {{ @filter.title }}: </a>
        """

      "date_period" ->
        ~H"""
        <a> {{ @filter.title }}: </a>
        """

      "date" ->
        ~H"""
        <a> {{ @filter.title }}: </a>
        """

      _ ->
        ~H"""
        <a> {{ @filter.title }}: </a>
        """
    end
  end
end
