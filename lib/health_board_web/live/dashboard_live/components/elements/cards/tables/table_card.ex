defmodule HealthBoardWeb.DashboardLive.Components.TableCard do
  use Surface.Component
  alias HealthBoardWeb.DashboardLive.Components.ElementsFragments
  alias Phoenix.LiveView

  prop card, :map, required: true
  prop params, :map, default: %{}

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    data = %{
      lines: [
        %{cells: ["São Paulo", "14.776"]},
        %{cells: ["Minas Gerais", "8.318"]},
        %{cells: ["Paraná", "4.491"]},
        %{cells: ["Rio de Janeiro", "3.678"]},
        %{cells: ["Bahia", "3.645"]},
        %{cells: ["Goiás", "3.568"]},
        %{cells: ["Rio Grande do Sul", "3.411"]},
        %{cells: ["Santa Catarina", "2.564"]},
        %{cells: ["Pará", "2.272"]},
        %{cells: ["Amazonas", "1.852"]}
      ]
    }

    ~H"""
    <ElementsFragments.Card
      :let={{ data: _data }}
      element={{ @card }}
      params={{ @params }}
      wrapper_class="flex flex-col place-content-evenly rounded-lg shadow-md overflow-x-auto"
    >
      <table :if={{ Enum.any?(data) }} class="table-auto border-collapse w-full">
        <thead>
          <tr class="text-sm text-left text-gray-600">
            <th :if={{ @params[:with_index] == true }} ></th>
            <th :for={{ header <- Map.get(@params, :headers, []) }} >
              {{ header }}
            </th>
          </tr>
        </thead>

        <tbody :if={{ @params[:with_index] == true }}>
          <tr
            :for.with_index={{ {line, index} <- fetch_lines(data, @params) }}
            class="text-sm text-left hover:bg-gray-100"
          >
            <td>{{ index + 1 }}</td>
            <td :for={{ cell <- Map.get(line, :cells, []) }}>
              {{ cell }}
            </td>
          </tr>
        </tbody>

        <tbody :if={{ @params[:with_index] != true }}>
          <tr
            :for={{ line <- fetch_lines(data, @params) }}
            class="text-sm text-left hover:bg-gray-100"
          >
            <td :for={{ cell <- Map.get(line, :cells, []) }}>
              {{ cell }}
            </td>
          </tr>
        </tbody>
      </table>

      <p :if={{ Enum.empty?(data) }} class="text-2xl font-bold">
        N/A
      </p>
    </ElementsFragments.Card>
    """
  end

  defp fetch_lines(data, params) do
    data
    |> Map.get(:lines, [])
    |> Enum.slice(params[:slice] || 0..-1)
  end
end
