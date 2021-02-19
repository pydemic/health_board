defmodule HealthBoardWeb.Helpers.Humanize do
  alias HealthBoard.Contexts.Geo.Locations
  alias HealthBoardWeb.Cldr

  @spec location(Locations.schema() | nil, keyword) :: String.t()
  def location(location, _options \\ []) do
    case location do
      %{verbose_name: name} when is_binary(name) -> name
      _location -> "N/A"
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
end
