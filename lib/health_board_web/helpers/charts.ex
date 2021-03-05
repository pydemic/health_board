defmodule HealthBoardWeb.Helpers.Charts do
  @spec combo(list(map), String.t(), list(String.t() | number), keyword) :: map
  def combo(datasets, label, labels, _opts \\ []) do
    %{
      subType: "combo",
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: datasets
        },
        options: %{
          maintainAspectRatio: false,
          tooltips: %{
            mode: "index",
            intersect: false
          },
          scales: %{
            xAxes: [
              %{
                scaleLabel: %{
                  display: true,
                  labelString: label
                }
              }
            ]
          }
        }
      }
    }
  end

  @spec line(list(number), String.t(), list(String.t() | number), keyword) :: map
  def line(data, label, labels, opts \\ []) do
    border_color = Keyword.get(opts, :border_color, "#36a2eb")
    background_color = Keyword.get(opts, :background_color, "rgba(54, 162, 235, 0.2)")

    %{
      subType: "line",
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: label,
              data: data,
              backgroundColor: background_color,
              borderColor: border_color,
              borderWidth: 1
            }
          ]
        },
        options: %{
          maintainAspectRatio: false,
          legend: false
        }
      }
    }
  end
end
