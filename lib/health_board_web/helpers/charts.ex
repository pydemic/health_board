defmodule HealthBoardWeb.Helpers.Charts do
  @spec combo(list(map), String.t(), list(String.t() | number), keyword) :: map
  def combo(datasets, label, labels, _opts \\ []) do
    %{
      timestamp: :os.system_time(),
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

  @spec line(list(map), list(String.t() | number), keyword) :: map
  def line(datasets, labels, opts \\ []) do
    %{
      timestamp: :os.system_time(),
      subType: "line",
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: datasets
        },
        options:
          %{
            maintainAspectRatio: false,
            hover: %{
              mode: "index",
              intersect: false
            },
            tooltips: %{
              mode: "index",
              intersect: false
            }
          }
          |> maybe_disable_legends(opts)
      }
    }
  end

  defp maybe_disable_legends(options, opts) do
    if Keyword.get(opts, :show_legends?, false) do
      options
    else
      Map.put(options, :legend, false)
    end
  end

  @spec line_dataset(list(number), String.t(), keyword) :: map
  def line_dataset(data, label, opts \\ []) do
    dataset = %{
      data: data,
      label: label,
      borderWidth: Keyword.get(opts, :border_width, 1),
      pointRadius: Keyword.get(opts, :point_radius, 3),
      hidden: Keyword.get(opts, :hidden, false) == true
    }

    {r, g, b} = pick_color(Keyword.get(opts, :index, 0))

    color = "rgb(#{r}, #{g}, #{b})"
    transparent_color = "rgba(#{r}, #{g}, #{b}, 0.2)"

    case Keyword.get(opts, :colorize, :both) do
      :both -> %{backgroundColor: transparent_color, borderColor: color}
      :border -> %{backgroundColor: color, borderColor: color, fill: false}
      :background -> %{backgroundColor: transparent_color}
      _colorize -> %{}
    end
    |> Map.merge(dataset)
  end

  @spec pyramid_bar(list(number), list(number), String.t(), String.t(), list(String.t() | number), keyword) :: map
  def pyramid_bar(positive_data, negative_data, positive_label, negative_label, labels, opts \\ []) do
    positive_border_color = Keyword.get(opts, :positive_border_color, "#eba236")
    positive_background_color = Keyword.get(opts, :positive_background_color, "rgba(235, 162, 54, 0.2)")

    negative_border_color = Keyword.get(opts, :negative_border_color, "#36a2eb")
    negative_background_color = Keyword.get(opts, :negative_background_color, "rgba(54, 162, 235, 0.2)")

    %{
      timestamp: :os.system_time(),
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
      timestamp: :os.system_time(),
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

  @colors [
    {119, 139, 235},
    {243, 166, 131},
    {247, 215, 148},
    {231, 127, 103},
    {207, 106, 135},
    {241, 144, 102},
    {245, 205, 121},
    {84, 109, 229},
    {225, 95, 65},
    {196, 69, 105},
    {120, 111, 166},
    {248, 165, 194},
    {99, 205, 218},
    {234, 134, 133},
    {89, 98, 117},
    {87, 75, 144},
    {247, 143, 179},
    {61, 193, 211},
    {230, 103, 103},
    {48, 57, 82},
    {34, 112, 147},
    {71, 71, 135},
    {116, 185, 255},
    {162, 155, 254},
    {223, 230, 233},
    {0, 184, 148},
    {0, 206, 201},
    {9, 132, 227},
    {108, 92, 231},
    {178, 190, 195},
    {255, 234, 167},
    {250, 177, 160},
    {255, 118, 117},
    {253, 121, 168},
    {99, 110, 114},
    {253, 203, 110},
    {225, 112, 85},
    {52, 31, 151},
    {131, 149, 167},
    {34, 47, 62}
  ]

  @colors_size length(@colors)

  @spec pick_color(integer) :: {integer, integer, integer}
  def pick_color(index) do
    index = if @colors_size < index, do: rem(index, @colors_size), else: index
    Enum.at(@colors, index, List.first(@colors))
  end
end
