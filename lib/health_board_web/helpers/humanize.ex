defmodule HealthBoardWeb.Helpers.Humanize do
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

  @spec number(integer | float | Decimal.t() | nil, keyword) :: String.t()
  def number(number, options \\ []) do
    if is_nil(number) do
      "N/A"
    else
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
      case Cldr.Date.to_string(date) do
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
