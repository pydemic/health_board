defmodule HealthBoardWeb.DashboardLive.Renderings.JS do
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias Phoenix.{HTML, LiveView}

  @js_indicators_visualizations [:population_growth, :population_per_age_group, :population_per_sex]

  @spec render(map()) :: LiveView.Rendered.t()
  def render(assigns) do
    indicators_visualizations =
      assigns
      |> Map.get(:indicators_visualizations, %{})
      |> Map.take(@js_indicators_visualizations)

    if Enum.any?(Map.keys(indicators_visualizations)) do
      ~L"""
      <script>
        window.onload = () => {
          <%= for {key, data} <- indicators_visualizations do %>
            <%= js_data assigns, key, data %>
          <% end %>
        }
      </script>
      """
    end
  end

  defp js_data(assigns, :population_growth, data) do
    [from, to] =
      assigns
      |> Map.get(:filters, %{})
      |> Map.get(:year_period, [2000, 2020])

    data =
      from
      |> Range.new(to)
      |> Enum.to_list()
      |> Enum.zip(data)
      |> Enum.map(fn {year, data} ->
        %{
          label: "#{year}",
          data: [data],
          backgroundColor: "rgba(54, 162, 235, 0.2)",
          borderColor: "rgb(54, 162, 235)",
          borderWidth: 1
        }
      end)

    ~L"""
    let population_growth = new ChartJS(
      "population_growth",
      {
        type: "bar",
        data: {
          labels: ["População residente"],
          datasets: <%= HTML.raw Jason.encode!(data) %>
        },
        options: {
          legend: false
        }
      }
    )
    """
  end

  defp js_data(assigns, :population_per_age_group, data) do
    data =
      Enum.map(
        [
          {:age_0_4, "Entre 0 e 4 anos"},
          {:age_5_9, "Entre 5 e 9 anos"},
          {:age_10_14, "Entre 10 e 14 anos"},
          {:age_15_19, "Entre 15 e 19 anos"},
          {:age_20_24, "Entre 20 e 24 anos"},
          {:age_25_29, "Entre 25 e 29 anos"},
          {:age_30_34, "Entre 30 e 34 anos"},
          {:age_35_39, "Entre 35 e 39 anos"},
          {:age_40_44, "Entre 40 e 44 anos"},
          {:age_45_49, "Entre 45 e 49 anos"},
          {:age_50_54, "Entre 50 e 54 anos"},
          {:age_55_59, "Entre 55 e 59 anos"},
          {:age_60_64, "Entre 60 e 64 anos"},
          {:age_64_69, "Entre 65 e 69 anos"},
          {:age_70_74, "Entre 70 e 74 anos"},
          {:age_75_79, "Entre 75 e 79 anos"},
          {:age_80_or_more, "80 anos ou mais"}
        ],
        fn {key, label} ->
          %{
            label: label,
            data: [Map.get(data, key)],
            backgroundColor: "rgba(54, 162, 235, 0.2)",
            borderColor: "rgb(54, 162, 235)",
            borderWidth: 1
          }
        end
      )

    ~L"""
    let population_per_age_group = new ChartJS(
      "population_per_age_group",
      {
        type: "horizontalBar",
        data: {
          labels: ["População residente"],
          datasets: <%= HTML.raw Jason.encode!(data) %>
        },
        options: {
          legend: false,
          scales: {
            yAxes: [{
              ticks: {
                display: false
              }
            }]
          }
        }
      }
    )
    """
  end

  defp js_data(assigns, :population_per_sex, data) do
    ~L"""
    let population_per_sex = new ChartJS(
      "population_per_sex",
      {
        type: "doughnut",
        data: {
          labels: ["Masculino", "Feminino"],
          datasets: [
            {
              data: [<%= Map.get(data, :male) %>, <%= Map.get(data, :female) %>],
              backgroundColor: ["rgb(54,162,235)", "rgb(165,54,54)"]
            }
          ],
        },
        options: {
          legend: false
        }
      }
    )
    """
  end
end
