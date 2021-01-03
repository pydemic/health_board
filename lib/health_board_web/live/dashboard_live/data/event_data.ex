defmodule HealthBoardWeb.DashboardLive.EventData do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Helpers.Colors
  alias HealthBoardWeb.Router.Helpers, as: Routes

  @region Locations.context(:region)
  @state Locations.context(:state)
  @health_region Locations.context(:health_region)
  @city Locations.context(:city)

  @spec build(map, tuple) :: {String.t(), map | list(map)}
  def build(data, {type, sub_type}) do
    case type do
      :chart -> {"chart_data", build_chart_data(data, sub_type)}
      :map -> {"map_data", build_map_data(data, sub_type)}
      :picker -> build_picker_data(data, sub_type)
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

  defp build_choropleth_map_data(%{id: id, label: label, data: data, location: location} = payload) do
    %{
      id: id,
      label: label,
      data: data,
      geojson_path:
        Routes.geo_json_path(HealthBoardWeb.Endpoint, :show, geo_json_path(location, payload[:children_context])),
      tile_layer_url: Application.get_env(:health_board, :mapbox_layer_url)
    }
  end

  defp geo_json_path(%{context: context, id: id} = location, children_context) do
    cond do
      context == @city ->
        %{parents: [%{parent: %{id: health_region_id}}]} = Locations.preload_parent(location, @health_region)
        state_id = Locations.state_id(health_region_id, :health_region)
        region_id = Locations.region_id(state_id, :state)
        "76/#{region_id}/#{state_id}/#{health_region_id}/cities.geojson"

      context == @health_region ->
        state_id = Locations.state_id(id, :health_region)
        region_id = Locations.region_id(state_id, :state)

        case children_context do
          :health_region -> "76/#{region_id}/#{state_id}/health_regions.geojson"
          _children_context -> "76/#{region_id}/#{state_id}/#{id}/cities.geojson"
        end

      context == @state ->
        region_id = Locations.region_id(id, :state)

        case children_context do
          :city -> "76/#{region_id}/#{id}/cities.geojson"
          :state -> "76/#{region_id}/states.geojson"
          _children_context -> "76/#{region_id}/#{id}/health_regions.geojson"
        end

      context == @region ->
        case children_context do
          :city -> "76/#{id}/cities.geojson"
          :heath_region -> "76/#{id}/health_regions.geojson"
          :region -> "76/regions.geojson"
          _children_context -> "76/#{id}/states.geojson"
        end

      true ->
        case children_context do
          :city -> "76/cities.geojson"
          :heath_region -> "76/health_regions.geojson"
          :region -> "76/regions.geojson"
          _children_context -> "76/states.geojson"
        end
    end
  end

  defp build_picker_data(data, sub_type) do
    case sub_type do
      :date -> {"date_picker_data", build_date_picker_data(data)}
    end
  end

  defp build_date_picker_data(%{id: id, from: from, to: to, date: date}) do
    %{id: id, from: Date.to_iso8601(from), to: Date.to_iso8601(to), date: Date.to_iso8601(date)}
  end
end
