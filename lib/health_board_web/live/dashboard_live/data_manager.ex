defmodule HealthBoardWeb.DashboardLive.DataManager do
  alias HealthBoard.Contexts.Info
  alias HealthBoardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView

  @params %{
    "births_child_mass" => :atom,
    "births_child_masses" => {:list, :atom},
    "births_child_sex" => :atom,
    "births_deliveries" => {:list, :atom},
    "births_delivery" => :atom,
    "births_gestation_duration" => :atom,
    "births_gestation_durations" => {:list, :atom},
    "births_location_context" => :integer,
    "births_location" => :atom,
    "births_locations" => {:list, :atom},
    "births_mother_age" => :atom,
    "births_mother_ages" => {:list, :atom},
    "births_prenatal_consultation" => :atom,
    "births_prenatal_consultations" => {:list, :atom},
    "death_context" => :integer,
    "death_investigation" => :atom,
    "death_location_context" => :integer,
    "death_type" => :atom,
    "dengue_classification" => :atom,
    "dengue_classifications" => {:list, :atom},
    "dengue_serotype" => :atom,
    "dengue_serotypes" => {:list, :atom},
    "geo_cities" => {:list, :integer},
    "geo_city" => :integer,
    "geo_country" => :integer,
    "geo_health_region" => :integer,
    "geo_health_regions" => {:list, :integer},
    "geo_region" => :integer,
    "geo_regions" => {:list, :integer},
    "geo_state" => :integer,
    "geo_states" => {:list, :integer},
    "morbidities_location_context" => :integer,
    "person_age_group" => :atom,
    "person_age_groups" => {:list, :atom},
    "person_race" => :atom,
    "person_races" => {:list, :atom},
    "person_sex" => :atom,
    "time_date_period" => {:list, :date},
    "time_date" => :date,
    "time_week_period" => {:list, :integer},
    "time_week" => :integer,
    "time_year_period" => {:list, :integer},
    "time_year" => :integer
  }

  @spec initial_data(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def initial_data(socket, %{"dashboard_id" => id}) do
    case Info.Dashboards.get(id, preload_all?: true) do
      {:ok, dashboard} -> prepare_dashboard(socket, dashboard)
      _not_found -> LiveView.redirect(socket, to: Routes.home_path(socket, :index))
    end
  end

  @spec update(LiveView.Socket.t(), map()) :: LiveView.Socket.t()
  def update(socket, _params) do
    socket
  end

  defp prepare_dashboard(socket, dashboard) do
    socket
    |> import_filters(dashboard.filters)
    |> trigger_cards_events(dashboard.cards)
    |> LiveView.assign(:dashboard, dashboard)
  end

  defp import_filters(socket, filters) do
    LiveView.assign(socket, :filters, parse_filters(filters))
  end

  defp parse_filters(filters) do
    Enum.reduce(filters, %{}, &parse_filter/2)
  end

  defp parse_filter(%{filter_id: filter_id, value: value}, filters) do
    case Map.get(@params, filter_id) do
      nil -> filters
      type -> parse_value(filters, filter_id, type, value)
    end
  end

  defp parse_value(filters, filter_id, type, value) do
    case do_parse_value(type, value) do
      nil -> filters
      value -> Map.put(filters, filter_id, value)
    end
  end

  defp do_parse_value(type, value) do
    case type do
      :atom -> String.to_existing_atom(value)
      :date -> Date.from_iso8601!(value)
      :integer -> String.to_integer(value)
      {:list, type} -> Enum.map(String.split(value, ","), &do_parse_value(type, &1))
    end
  rescue
    _error -> nil
  end

  defp trigger_cards_events(socket, cards) do
    process = self()
    filters = socket.assigns.filters

    Enum.each(cards, &send(process, {:fetch_card_data, &1, filters}))

    socket
  end
end
