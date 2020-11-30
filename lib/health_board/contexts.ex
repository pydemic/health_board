defmodule HealthBoard.Contexts do
  @spec location_context(atom()) :: integer()
  def location_context(atom) do
    case atom do
      :residence -> 0
      :notification -> 1
    end
  end

  @spec morbidity_context(atom()) :: integer()
  def morbidity_context(atom) do
    base_value = 10_000
    base_multiplier = 100

    case atom do
      :botulism -> 0 * base_multiplier + base_value
      :chikungunya -> 1 * base_multiplier + base_value
      :cholera -> 2 * base_multiplier + base_value
      :hantavirus -> 3 * base_multiplier + base_value
      :human_rabies -> 4 * base_multiplier + base_value
      :malaria -> 5 * base_multiplier + base_value
      :plague -> 6 * base_multiplier + base_value
      :spotted_fever -> 7 * base_multiplier + base_value
      :yellow_fever -> 8 * base_multiplier + base_value
      :zika -> 9 * base_multiplier + base_value
    end
  end
end
