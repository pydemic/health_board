defmodule HealthBoardWeb.DashboardLive.Components.Dashboard.Header do
  use Surface.Component
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop groups, :list, required: true
  prop group_index, :integer, required: true

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <header class="lg:px-10 sm:px-6 px-4 w-full bg-indigo-500 divide-y divide-white">
      <div class="justify-between items-center flex">
        <div class="text-white py-5 text-2xl font-bold">
          <h2>{{ @name }}</h2>
        </div>
      </div>
      <div class="text-white w-full py-5 justify-between items-center flex overflow-x-auto whitespace-nowrap">
        <a
          :for.with_index={{ {%{child: group}, index} <- @groups }}
          href="/"
          class={{ "px-2", "rounded-full", "bg-white": @group_index == index, "text-indigo-500": @group_index == index }}
        >
          {{ group.name }}
        </a>
      </div>
    </header>
    """
  end
end
