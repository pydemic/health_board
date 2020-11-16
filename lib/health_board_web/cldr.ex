defmodule HealthBoardWeb.Cldr do
  use Cldr,
    default_locale: "pt",
    locales: ["pt"],
    otp_app: :health_board,
    providers: [Cldr.Calendar, Cldr.DateTime, Cldr.Number]
end
