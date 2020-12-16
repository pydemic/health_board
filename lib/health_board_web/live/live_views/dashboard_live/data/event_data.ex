defmodule HealthBoardWeb.DashboardLive.EventData do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Helpers.Colors
  alias HealthBoardWeb.Router.Helpers, as: Routes

  @spec build(map, tuple) :: {String.t(), map | list(map)}
  def build(data, {type, sub_type}) do
    case type do
      :chart -> {"chart_data", build_chart_data(data, sub_type)}
      :map -> {"map_data", build_map_data(data, sub_type)}
    end
  end

  defp build_chart_data(data, sub_type) do
    case sub_type do
      :combo -> combo_chart_data(data)
      :horizontal_bar -> horizontal_bar_data(data)
      :line -> line_chart_data(data)
      :multiline -> multiline_chart_data(data)
      :pyramid_bar -> pyramid_bar_data(data)
      :vertical_bar -> vertical_bar_data(data)
    end
  end

  defp combo_chart_data(%{id: id, datasets: datasets, labels: labels, labelString: label_string}) do
    %{
      id: id,
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
                  labelString: label_string
                }
              }
            ]
          }
        }
      }
    }
  end

  defp horizontal_bar_data(%{id: id, labels: labels, label: label, data: data}) do
    {background_color, border_color} = Colors.blue_with_border()

    %{
      id: id,
      subType: "horizontalBar",
      data: %{
        type: "horizontalBar",
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

  defp line_chart_data(%{id: id, labels: labels, label: label, data: data}) do
    {background_color, border_color} = Colors.blue_with_border()

    %{
      id: id,
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

  defp multiline_chart_data(%{id: id, datasets: datasets, labels: labels}) do
    datasets =
      datasets
      |> Enum.zip(Colors.divergents(Enum.count(datasets)))
      |> Enum.map(fn {dataset, color} ->
        Map.merge(dataset, %{backgroundColor: color, borderColor: color, fill: false})
      end)

    %{
      id: id,
      subType: "multiline",
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

  defp pyramid_bar_data(data) do
    %{
      id: id,
      labels: labels,
      positive_label: positive_label,
      negative_label: negative_label,
      positive_data: positive_data,
      negative_data: negative_data
    } = data

    {red_background_color, red_border_color} = Colors.red_with_border()
    {blue_background_color, blue_border_color} = Colors.blue_with_border()

    %{
      id: id,
      subType: "pyramidBar",
      data: %{
        type: "horizontalBar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: negative_label,
              data: Enum.map(negative_data, fn v -> -v end),
              backgroundColor: blue_background_color,
              borderColor: blue_border_color,
              borderWidth: 1
            },
            %{
              label: positive_label,
              data: positive_data,
              backgroundColor: red_background_color,
              borderColor: red_border_color,
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

  defp vertical_bar_data(%{id: id, labels: labels, label: label, data: data}) do
    {background_color, border_color} = Colors.blue_with_border()

    %{
      id: id,
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

  defp build_map_data(data, sub_type) do
    case sub_type do
      :choropleth -> build_choropleth_map_data(data)
    end
  end

  defp build_choropleth_map_data(%{id: id, label: label, data: data, location: location}) do
    %{
      id: id,
      label: label,
      data: data,
      geojson_path: Routes.geo_json_path(HealthBoardWeb.Endpoint, :show, geo_json_path(location)),
      tile_layer_url: Application.get_env(:health_board, :mapbox_layer_url)
    }
  end

  defp geo_json_path(%{context: context, id: id, parent_id: parent_id}) do
    cond do
      context == Locations.context!(:city) ->
        "76/#{div(parent_id, 10_000)}/#{div(parent_id, 1_000)}/#{parent_id}/cities.geojson"

      context == Locations.context!(:health_region) ->
        "76/#{div(id, 10_000)}/#{div(id, 1_000)}/#{id}/cities.geojson"

      context == Locations.context!(:state) ->
        "76/#{div(id, 10)}/#{id}/health_regions.geojson"

      context == Locations.context!(:region) ->
        "76/#{id}/states.geojson"

      true ->
        "76/states.geojson"
    end
  end
end
