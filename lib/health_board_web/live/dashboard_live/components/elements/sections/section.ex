defmodule HealthBoardWeb.DashboardLive.Components.Section do
  use Surface.Component
  alias __MODULE__.FiltersTags
  alias HealthBoardWeb.DashboardLive.Components.{DataWrapper, DynamicElement}
  alias Phoenix.LiveView

  prop section, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <DataWrapper id={{ @section.id }} :let={{ data: _data }} wrapper_class="p-5 border border-hb-aa dark:border-hb-aa-dark border-opacity-20 rounded-lg">
      <h1 class="mb-1 text-xl font-bold">
        {{ @section.name }}
      </h1>

      <FiltersTags id={{ @section.id }} name={{ @section.name }} filters={{ @section.filters }} params={{ @params }} />

      <div class={{ section_class(@params) }}>
        <DynamicElement :for={{ %{child: card} <- @section.children }} element={{ card }} />
      </div>
    </DataWrapper>
    """
  end

  defp section_class(params) do
    case Map.get(params, "responsive_cols") do
      "3" -> "md:grid-cols-2 lg:grid-cols-3"
      "2" -> "lg:grid-cols-2"
      _result -> "grid-cols-1"
    end <> " grid place-items-stretch gap-4 mt-5"
  end
end
