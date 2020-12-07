defmodule HealthBoardWeb.DashboardLive.EventData do
  alias HealthBoardWeb.Helpers.Colors

  @spec build(map, tuple) :: {String.t(), map | list(map)}
  def build(data, {type, sub_type}) do
    case type do
      :chart -> {"chart_data", build_chart_data(data, sub_type)}
      :map -> {"map_data", %{}}
    end
  end

  defp build_chart_data(data, sub_type) do
    case sub_type do
      :combo -> combo_chart_data(data)
      :horizontal_bar -> %{}
      :line -> %{}
      :multiline -> multiline_chart_data(data)
      :pie -> %{}
      :vertical_bar -> %{}
    end
  end

  defp combo_chart_data(%{id: id, datasets: datasets, labels: labels, labelString: label_string}) do
    %{
      id: id,
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: datasets
        },
        options: %{
          maintainAspectRatio: false,
          scales: %{
            xAxes: [
              %{
                scaleLabel: %{
                  display: true,
                  labelString: label_string
                }
              }
            ]
          }
        }
      }
    }
  end

  defp multiline_chart_data(%{id: id, datasets: datasets, labels: labels}) do
    datasets =
      datasets
      |> Enum.zip(Colors.divergents(Enum.count(datasets)))
      |> Enum.map(fn {dataset, color} ->
        Map.merge(dataset, %{backgroundColor: color, borderColor: color, fill: false})
      end)

    %{
      id: id,
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: datasets
        },
        options: %{
          maintainAspectRatio: false
        }
      }
    }
  end
end
