defmodule HealthBoardWeb.DashboardLive.Components.HeatmapTableCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.Card
  alias HealthBoardWeb.DashboardLive.Components.Fragments.{MaybeLink, NA, Otherwise}
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <Card
      :let={{ data: data }}
      element={{ @card }}
      params={{ @params }}
      extra_wrapper_class="overflow-x-auto"
    >
      <Otherwise condition={{ Enum.any?(data) and Enum.any?(data[:lines] || []) }}>
        <table :if={{ Enum.any?(data) and Enum.any?(data[:lines] || []) }} class="table-auto border-collapse w-full text-xs">
          <thead>
            <tr class="text-left text-hb-ca-dark dark:text-hb-b-dark">
              <th :for={{ header <- @params[:headers] || data[:headers] || [] }}>
                {{ header }}
              </th>
            </tr>
          </thead>

          <tbody>
            <tr :for={{ line <- fetch_lines(data, @params) }} class="text-left hover:bg-hb-c dark:hover:bg-hb-c-dark whitespace-nowrap">
              <td :for={{ cell <- Map.get(line, :cells, []) }} class={{ "bg-hb-choropleth-#{cell[:group]}": cell[:group], "bg-opacity-90": true, "text-center": cell[:group] }}>
                <MaybeLink value={{ cell[:value] }} link={{ cell[:link] }} params={{ @card.params }} />
              </td>
            </tr>
          </tbody>
        </table>
        <template slot="otherwise">
          <NA />
        </template>
      </Otherwise>
    </Card>
    """
  end

  defp fetch_lines(data, params) do
    data
    |> Map.get(:lines, [])
    |> Enum.slice(params[:slice] || 0..-1)
  end
end
