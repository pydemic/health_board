const colors = require("tailwindcss/colors")

module.exports = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "hb-a": { DEFAULT: colors.blueGray[50], dark: colors.blueGray[800] }, // Background
        "hb-aa": { DEFAULT: colors.lightBlue[600], dark: colors.lightBlue[900] }, // Alternative background
        "hb-b": { DEFAULT: colors.trueGray[900], dark: colors.coolGray[400] }, // Text
        "hb-ba": { DEFAULT: colors.blueGray[50], dark: colors.coolGray[400] }, // Alternative text
        "hb-c": { DEFAULT: colors.lightBlue[100], dark: colors.blueGray[700] }, // Common hover
        "hb-ca": { DEFAULT: colors.lightBlue[700], dark: colors.blueGray[700] }, // Alternative hover
        "hb-choropleth-0": { DEFAULT: colors.gray[600], dark: colors.gray[800] },
        "hb-choropleth-1": { DEFAULT: "#e38191", dark: colors.green[800] },
        "hb-choropleth-2": { DEFAULT: "#cc607d", dark: colors.lime[800] },
        "hb-choropleth-3": { DEFAULT: "#ad466c", dark: colors.yellow[600] },
        "hb-choropleth-4": { DEFAULT: "#8b3058", dark: colors.amber[800] },
        "hb-choropleth-5": { DEFAULT: "#672044", dark: colors.orange[800] },
        "hb-choropleth-success": { DEFAULT: "#00b894" },
        "hb-choropleth-warning": { DEFAULT: "#ffeaa7" },
        "hb-choropleth-alert": { DEFAULT: "#fdcb6e" },
        "hb-choropleth-danger": { DEFAULT: "#e17055" },
        "hb-choropleth-critical": { DEFAULT: "#d63031" },
      },
      zIndex: {
        '900': 900,
        '1000': 1000,
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
