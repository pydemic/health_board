defmodule HealthBoardWeb.DashboardLive.IndicatorsData.EventData do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias HealthBoardWeb.DashboardLive.IndicatorsData
  alias HealthBoardWeb.Helpers.Humanize

  @grey "#aaaaaa"
  @blue "rgba(54, 162, 235, 0.2)"
  @blue_border "#36a2eb"

  @spec build(IndicatorsData.t(), atom(), atom()) :: {String.t(), any()}
  def build(indicators_data, type, sub_type) do
    case type do
      :chart -> {"chart_data", build_chart_data(indicators_data, sub_type)}
      :map -> {"map_data", build_map_data(indicators_data, sub_type)}
    end
  end

  defp build_chart_data(indicators_data, sub_type) do
    case sub_type do
      :combo -> combo_chart_data(indicators_data)
      :horizontal_bar -> horizontal_bar_chart_data(indicators_data)
      :line -> line_chart_data(indicators_data)
      :multiline -> multiline_chart_data(indicators_data)
      :pie -> pie_chart_data(indicators_data)
      :vertical_bar -> vertical_bar_chart_data(indicators_data)
    end
  end

  defp combo_chart_data(indicators_data) do
    %{id: id, card: %{indicator: %{name: name}}, extra: %{labels: labels}, result: datasets} = indicators_data

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
            yAxes: [
              %{
                scaleLabel: %{
                  display: true,
                  labelString: name
                }
              }
            ]
          }
        }
      }
    }
  end

  defp horizontal_bar_chart_data(indicators_data) do
    %{id: id, card: %{indicator: %{name: name}}, extra: %{labels: labels}, result: result} = indicators_data

    labels = Enum.map(result, &Map.get(labels, &1.field, "N/A"))
    data = Enum.map(result, & &1.value)

    %{
      id: id,
      data: %{
        type: "horizontalBar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: name,
              data: data,
              backgroundColor: @blue,
              borderColor: @blue_border,
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
                  labelString: name
                }
              }
            ]
          }
        }
      }
    }
  end

  defp line_chart_data(%{id: id, card: %{indicator: %{name: name}}, extra: %{labels: labels}, result: result}) do
    data = Enum.map(result, & &1.value)

    %{
      id: id,
      data: %{
        type: "line",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: name,
              data: data,
              backgroundColor: @blue,
              borderColor: @blue_border,
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

  defp multiline_chart_data(%{id: id, extra: %{labels: labels}, result: result}) do
    colors = get_color_list(Enum.count(result), :divergent)
    datasets = Enum.map(Enum.zip(result, colors), &colorize_dataset/1)

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

  defp colorize_dataset({dataset, color}) do
    dataset
    |> Map.put(:backgroundColor, color)
    |> Map.put(:borderColor, color)
    |> Map.put(:fill, false)
  end

  defp pie_chart_data(%{id: id, extra: %{labels: labels}, result: result}) do
    labels = Enum.map(result, &Map.get(labels, &1.field, "N/A"))
    data = Enum.map(result, & &1.value)

    %{
      id: id,
      data: %{
        type: "pie",
        data: %{
          labels: labels,
          datasets: [
            %{
              data: data,
              backgroundColor: get_color_list(Enum.count(labels), :gradative)
            }
          ]
        },
        options: %{
          maintainAspectRatio: false
        }
      }
    }
  end

  defp vertical_bar_chart_data(indicators_data) do
    %{id: id, card: %{indicator: %{name: name}}, extra: %{labels: labels}, result: result} = indicators_data

    labels = Enum.map(result, &Map.get(labels, &1.field, "N/A"))
    data = Enum.map(result, & &1.value)

    %{
      id: id,
      data: %{
        type: "bar",
        data: %{
          labels: labels,
          datasets: [
            %{
              label: name,
              data: data,
              backgroundColor: @blue,
              borderColor: @blue_border,
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
                  labelString: name
                }
              }
            ]
          }
        }
      }
    }
  end

  defp build_map_data(indicators_data, sub_type) do
    case sub_type do
      :shape_color -> build_shape_color_map_data(indicators_data)
    end
  end

  defp build_shape_color_map_data(indicators_data) do
    %{
      id: id,
      card: %{indicator: %{name: name}},
      data: %{ranges: ranges},
      extra: %{locations: [location | _locations] = locations},
      result: result
    } = indicators_data

    result_with_color = Enum.map(result, &add_color(&1, ranges))

    %{
      id: id,
      value_name: name,
      data: Enum.map(locations, &do_build_map_data(&1, result_with_color)),
      geojson_path: get_geojson_path(indicators_data, location),
      tile_layer_url: Application.get_env(:health_board, :mapbox_layer_url)
    }
  end

  defp add_color(%{value: value} = map, ranges) do
    %{color: color} = Enum.find(ranges, %{color: @grey}, &on_boundary?(value, &1))
    Map.put(map, :color, color)
  end

  defp do_build_map_data(location, values) do
    %{id: id, name: name} = location
    %{color: color, value: value} = Enum.find(values, %{color: @grey, value: 0}, &(&1.location_id == id))
    %{id: id, name: name, value: value, formatted_value: Humanize.number(value), color: color}
  end

  defp get_geojson_path(%{socket: socket}, %{parent_id: parent_id, level: level}) do
    Routes.geo_json_path(socket, :show, get_geojson_relative_path(level, parent_id))
  end

  defp get_geojson_relative_path(level, parent_id) do
    cond do
      level == Locations.city_level() -> get_cities_geojson_path(parent_id)
      level == Locations.health_region_level() -> get_health_regions_geojson_path(parent_id)
      level == Locations.state_level() -> get_states_geojson_path()
      level == Locations.region_level() -> get_regions_geojson_path()
      true -> ""
    end
  end

  defp get_cities_geojson_path(parent_id) do
    "76/#{div(parent_id, 10_000)}/#{div(parent_id, 1_000)}/#{parent_id}/cities.geojson"
  end

  defp get_health_regions_geojson_path(parent_id) do
    "76/#{div(parent_id, 10)}/#{parent_id}/health_regions.geojson"
  end

  defp get_states_geojson_path do
    "76/states.geojson"
  end

  defp get_regions_geojson_path do
    "76/regions.geojson"
  end

  defp on_boundary?(value, boundary) do
    case boundary do
      %{from: nil, to: to} -> value <= to
      %{from: from, to: nil} -> value >= from
      %{from: from, to: to} -> value >= from and value <= to
    end
  end

  @spec create_ranges(IndicatorsData.t(), atom()) :: list(map())
  def create_ranges(indicators_data, type) do
    case type do
      :quintile -> create_quintile(indicators_data)
    end
  end

  defp create_quintile(%{extra: %{value_type: value_type}, result: result}) do
    data = Enum.map(result, & &1.value)
    round_function = if value_type == :integer, do: &round/1, else: & &1

    {q0, q1, q2, q3, q4} =
      try do
        {
          round_function.(0.0),
          round_function.(Statistics.percentile(data, 20)),
          round_function.(Statistics.percentile(data, 40)),
          round_function.(Statistics.percentile(data, 60)),
          round_function.(Statistics.percentile(data, 80))
        }
      rescue
        _error -> {0, 0, 0, 0, 0}
      end

    [c1, c2, c3, c4, c5] = get_color_list(5, :gradative)

    [
      %{text: create_quintile_text(nil, q0), from: nil, to: q0, color: @grey},
      %{text: create_quintile_text(q0, q1), from: q0, to: q1, color: c1},
      %{text: create_quintile_text(q1, q2), from: q1, to: q2, color: c2},
      %{text: create_quintile_text(q2, q3), from: q2, to: q3, color: c3},
      %{text: create_quintile_text(q3, q4), from: q3, to: q4, color: c4},
      %{text: create_quintile_text(q4, nil), from: q4, to: nil, color: c5}
    ]
    |> Enum.reject(&is_nil(&1.text))
  end

  defp create_quintile_text(from, to) do
    case {from, to} do
      {nil, to} ->
        Humanize.number(to)

      {0, nil} ->
        nil

      {from, from} ->
        nil

      {from, to} when from > to ->
        nil

      {from, nil} ->
        "Maior que " <> Humanize.number(from)

      {from, to} ->
        "Maior que " <> Humanize.number(from) <> " e menor ou igual a " <> Humanize.number(to)
    end
  end

  defp get_color_list(amount, :gradative) do
    case amount do
      2 -> ~w[#003f5c #bc5090]
      3 -> ~w[#003f5c #bc5090 #ffa600]
      5 -> ~w[#003f5c #58508d #bc5090 #ff6361 #ffa600]
      6 -> ~w[#003f5c #58508d #e4537d #bc5090 #ff6361 #ffa600]
      10 -> ~w[#003f5c #3f4d84 #8b5196 #d15088 #e4537d #ff6361 #ff7150 #ff813d #ff9327 #ffa600]
    end
  end

  defp get_color_list(amount, :divergent) do
    case amount do
      6 -> ~w[#00aaaa #3d914b #7c6800 #aa0000 #b00038 #920072]
      10 -> ~w[#00aaaa #3d914b #7c6800 #aa0000 #b00038 #920072 #4655aa #b2438a #d6544c #bb8811]
    end
  end
end
