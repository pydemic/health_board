defmodule HealthBoardWeb.LiveComponents.CardOffcanvasDescription do
  use Surface.Component

  alias HealthBoardWeb.Helpers.Humanize
  alias Phoenix.LiveView

  prop data, :any

  @spec render(map) :: LiveView.Rendered.t()
  def render(assigns) do
    data = flatten_data(assigns[:data])

    ~H"""
    <dl class={{"uk-description-list", "hb-description-list"}} :for={{ {title, description} <- data }}>
      <dt :if={{ (not is_nil(title)) and is_nil(description) }}><h3>{{ title }}</h3></dt>
      <dd :if={{ (not is_nil(description)) and is_nil(title) }}>- {{ description }}</dd>
      <dt :if={{ (not is_nil(title)) and (not is_nil(description))}}>{{ title }}</dt>
      <dd :if={{ (not is_nil(description)) and (not is_nil(title))}}>{{ description }}</dd>
    </dl>
    """
  end

  defp flatten_data(map) do
    map
    |> Map.to_list()
    |> do_flatten([])
    |> Enum.reverse()
  end

  defp do_flatten([], acc), do: acc

  defp do_flatten([{k, %Date{} = v} | rest], acc) do
    do_flatten(rest, [{Humanize.format(k), Humanize.date(v)} | acc])
  end

  defp do_flatten([{k, %DateTime{} = v} | rest], acc) do
    do_flatten(rest, [{Humanize.format(k), Humanize.date_time(v)} | acc])
  end

  defp do_flatten([{k, v} | rest], acc) when is_map(v) do
    do_flatten(Map.to_list(v) ++ rest, [{Humanize.format(k), nil} | acc])
  end

  defp do_flatten([{k, v} | rest], acc) when is_list(v) do
    do_flatten(rest, do_flatten(v, [{Humanize.format(k), nil} | acc]))
  end

  defp do_flatten([{k, v} | rest], acc) do
    do_flatten(rest, [{Humanize.format(k), Humanize.format(v)} | acc])
  end

  defp do_flatten([v | rest], acc) when is_map(v) do
    do_flatten(Map.to_list(v) ++ rest, acc)
  end

  defp do_flatten([v | rest], acc) when is_list(v) do
    do_flatten(v ++ rest, acc)
  end

  defp do_flatten([v | rest], acc) do
    do_flatten(rest, [{nil, Humanize.format(v)} | acc])
  end
end
