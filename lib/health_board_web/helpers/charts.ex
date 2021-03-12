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

  @spec pyramid_bar(list(number), list(number), String.t(), String.t(), list(String.t() | number), keyword) :: map
  def pyramid_bar(positive_data, negative_data, positive_label, negative_label, labels, opts \\ []) do
    positive_border_color = Keyword.get(opts, :positive_border_color, "#eba236")
    positive_background_color = Keyword.get(opts, :positive_background_color, "rgba(235, 162, 54, 0.2)")

    negative_border_color = Keyword.get(opts, :negative_border_color, "#36a2eb")
    negative_background_color = Keyword.get(opts, :negative_background_color, "rgba(54, 162, 235, 0.2)")

    %{
      subType: "pyramidBar",
      data: %{
        type: "horizontalBar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: negative_label,
              data: Enum.map(negative_data, fn v -> -v end),
              backgroundColor: negative_background_color,
              borderColor: negative_border_color,
              borderWidth: 1
            },
            %{
              label: positive_label,
              data: positive_data,
              backgroundColor: positive_background_color,
              borderColor: positive_border_color,
              borderWidth: 1
            }
          ]
        },
        options: %{
          maintainAspectRatio: false,
          legend: false,
          tooltips: %{
            intersect: false,
            callbacks: %{
              label: nil
            }
          },
          scales: %{
            xAxes: [
              %{
                stacked: false,
                ticks: %{
                  beginAtZero: true,
                  callback: nil
                }
              }
            ],
            yAxes: [
              %{
                stacked: true
              }
            ]
          }
        }
      }
    }
  end

  @spec vertical_bar(list(map), String.t(), list(String.t() | number), keyword) :: map
  def vertical_bar(data, label, labels, opts \\ []) do
    border_color = Keyword.get(opts, :border_color, "#36a2eb")
    background_color = Keyword.get(opts, :background_color, "rgba(54, 162, 235, 0.2)")

    %{
      subType: "verticalBar",
      data: %{
        type: "bar",
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
          legend: false,
          scales: %{
            yAxes: [
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
end
