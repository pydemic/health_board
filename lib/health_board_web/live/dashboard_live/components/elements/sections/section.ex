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
    <DataWrapper id={{ @section.id }} :let={{ data: _data }} wrapper_class="border-2 border-gray-100 rounded-lg mb-6">
      <div class="mx-auto py-5 px-4 sm:px-6 lg:px-8">
        <h1 class="text-xl font-bold leading-tight text-gray-900 mb-2">
          {{ @section.name }}
        </h1>

        <FiltersTags id={{ @section.id }} name={{ @section.name }} filters={{ @section.filters }} params={{ @params }} />
      </div>

      <div class={{ section_class(@params) }}>
        <DynamicElement :for={{ %{child: card} <- @section.children }} element={{ card }} />
      </div>
    </DataWrapper>
    """
  end

  defp section_class(params) do
    case Map.get(params, "responsive_cols") do
      "3" -> three_cols_section()
      "2" -> two_cols_section()
      _result -> single_col_section()
    end <> " grid pb-5 px-4 sm:px-6 lg:px-8 place-items-stretch gap-4"
  end

  defp single_col_section, do: "grid-cols-1"
  defp two_cols_section, do: "lg:grid-cols-2 2xl:grid-cols-3"
  defp three_cols_section, do: "md:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-4"
end
