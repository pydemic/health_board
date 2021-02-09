defmodule HealthBoardWeb.Helpers.Humanize do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Cldr
  alias Phoenix.Naming

  @keys_name %{
    above_average: "Acima da média",
    average: "Média",
    below_average: "Abaixo da média",
    births: "Nascidos vivos",
    deaths: "Óbitos",
    extraction_date: "Data de extração",
    female: "Feminino",
    first_record_date: "Data do primeiro registro",
    from_year: "Início do período anual",
    last_record_date: "Data do último registro",
    last_update_date: "Data da última atualização",
    location: "Localidade",
    locations: "Localidades",
    male: "Masculino",
    morbidity_context: "Doença, agravo ou evento de saúde pública de notificação compulsória",
    morbidity_contexts: "Doenças, agravos e eventos de saúde pública de notificação compulsória",
    morbidity: "Casos",
    on_average: "Na média",
    overall_severity: "Situação geral",
    population: "População residente",
    rate: "Taxa",
    ratio: "Razão",
    severity: "Situação",
    to_year: "Término do período anual",
    year: "Ano"
  }

  @spec format(any) :: String.t()
  def format(value) do
    case value do
      %Date{} -> date(value)
      %DateTime{} -> date_time(value)
      value when is_integer(value) or is_float(value) -> number(value)
      value when is_nil(value) -> "N/A"
      value when is_atom(value) -> translate_key(value)
      _value -> value
    end
  end

  @spec location(Locations.schema() | nil, keyword) :: String.t()
  def location(location, _options \\ []) do
    if is_nil(location) or Map.get(location, :__struct__) == Ecto.Association.NotLoaded do
      "N/A"
    else
      case Locations.group_atom(location.group) do
        :countries -> location.name
        :regions -> "Região #{location.name}"
        :states -> location.name
        :health_regions -> "Regional de saúde #{location.name} - #{parent_state_abbr(location)}"
        :cities -> "#{location.name} - #{parent_state_abbr(location)}"
      end
    end
  end

  defp parent_state_abbr(%{parents: parents} = location) do
    states_group = Locations.group(:states)

    if is_list(parents) do
      case Enum.find(parents, &(&1.parent_group == states_group)) do
        %{parent: %{abbr: abbr}} -> abbr
        _result -> "N/A"
      end
    else
      location
      |> Locations.preload_parent(states_group)
      |> parent_state_abbr()
    end
  end

  @spec number(integer | float | Decimal.t() | nil, keyword) :: String.t()
  def number(number, options \\ []) do
    if is_nil(number) do
      "N/A"
    else
      options = if is_float(number), do: Keyword.put_new(options, :fractional_digits, 1), else: options

      case Cldr.Number.to_string(number, options) do
        {:ok, humanized_number} -> humanized_number
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec date(Date.t() | nil) :: String.t()
  def date(date) do
    if is_nil(date) do
      "N/A"
    else
      case Cldr.Date.to_string(date, format: :long) do
        {:ok, humanized_date} -> humanized_date
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec date_time(DateTime.t() | nil) :: String.t()
  def date_time(date_time) do
    if is_nil(date_time) do
      "N/A"
    else
      case Cldr.DateTime.to_string(date_time) do
        {:ok, humanized_date_time} -> humanized_date_time
        {:error, _reason} -> "N/A"
      end
    end
  end

  @spec translate_key(atom) :: String.t()
  def translate_key(key) do
    Map.get(@keys_name, key, Naming.humanize(key))
  end
end
