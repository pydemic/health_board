defmodule HealthBoardWeb.Helpers.Humanize do
  alias HealthBoardWeb.Cldr
  alias Phoenix.Naming

  @keys_name %{
    extraction_date: "Data de extração",
    last_case_date: "Data do último caso",
    year_deaths: "Óbitos anuais",
    year_morbidity: "Casos anuais",
    average: "Média",
    color: "Situação",
    success: "Abaixo da média",
    warning: "Na faixa média",
    danger: "Acima da média",
    morbidity_context: "Código da doença, agravo ou evento de saúde pública de notificação compulsória",
    time_from_year: "Início do período anual",
    time_to_year: "Término do período anual",
    time_year: "Ano"
  }

  @spec format(any) :: String.t()
  def format(value) do
    case value do
      %Date{} -> date(value)
      %DateTime{} -> date_time(value)
      value when is_integer(value) or is_float(value) -> number(value)
      value when is_nil(value) -> "N/A"
      value -> translate_key(value)
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

  @spec translate_key(String.t()) :: String.t()
  def translate_key(key) when is_binary(key) do
    translate_key(String.to_atom(key))
  end

  @spec translate_key(atom) :: String.t()
  def translate_key(key) do
    Map.get(@keys_name, key, Naming.humanize(key))
  end
end
