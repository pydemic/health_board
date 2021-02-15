defmodule HealthBoardWeb.DashboardLive.Components.Fragments.Select do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Icons.ChevronDown
  alias HealthBoardWeb.DashboardLive.Components.Fragments.Otherwise
  alias Phoenix.LiveView

  prop name, :string, required: true
  prop options, :any, required: true

  prop label, :string
  prop selected, :any, default: nil
  prop formatter, :fun

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <label :if={{ Map.has_key?(assigns, :label) }} for={{ @name }} class="block ml-3">{{ @label }}</label>

      <div class="relative inline-flex">
        <span class="ml-2 absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
          <ChevronDown svg_class="w-2 h-2 text-gray-700" />
        </span>

        <select name={{ @name }} class="border border-gray-300 rounded-full text-gray-600 pl-3 pr-6 bg-white hover:border-gray-400 focus:outline-none appearance-none">
          <Otherwise condition={{ is_function(assigns[:formatter]) }}>
            <option :for={{ value <- @options }} value={{ value }} selected={{ value == @selected }}>
              {{ @formatter.(value) }}
            </option>

            <template slot="otherwise">
              <option :for={{ value <- @options }} value={{ value }} selected={{ value == @selected }}>
                {{ value }}
              </option>
            </template>
          </Otherwise>
        </select>
      </div>
    </div>
    """
  end
end
