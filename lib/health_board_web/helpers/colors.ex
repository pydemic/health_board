defmodule HealthBoardWeb.Helpers.Colors do
  @divergent_colors ~w[#00aaaa #3d914b #7c6800 #aa0000 #b00038 #920072 #4655aa #b2438a #d6544c #bb8811]
  @divergent_colors_amount Enum.count(@divergent_colors)

  @spec divergents(non_neg_integer, list(String.t())) :: list(String.t())
  def divergents(amount, current_colors \\ []) do
    if amount > @divergent_colors_amount do
      divergents(
        amount - @divergent_colors_amount,
        Enum.slice(@divergent_colors, 0, @divergent_colors_amount) ++ current_colors
      )
    else
      Enum.slice(@divergent_colors, 0, amount) ++ current_colors
    end
  end
end
