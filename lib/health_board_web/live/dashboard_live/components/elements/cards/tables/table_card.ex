defmodule HealthBoardWeb.DashboardLive.Components.TableCard do
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
        <table :if={{ Enum.any?(data) and Enum.any?(data[:lines] || []) }} class="table-auto border-collapse w-full">
          <thead>
            <tr class="text-sm text-left text-hb-ca-dark dark:text-hb-b-dark">
              <th :if={{ @params[:with_index] == true }} ></th>
              <th :for={{ header <- @params[:headers] || data[:headers] || [] }} >
                {{ header }}
              </th>
            </tr>
          </thead>

          <tbody>
            <tr :for.with_index={{ {line, index} <- fetch_lines(data, @params) }} class="text-sm text-left hover:bg-hb-c dark:hover:bg-hb-c-dark">
              <td :if={{ @params[:with_index] == true }} class="text-right pr-2">
                {{ index + 1 }}
              </td>

              <td :for={{ cell <- Map.get(line, :cells, []) }} class={{ "bg-hb-choropleth-#{cell[:group]}": cell[:group], "text-center": cell[:group] }}>
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
