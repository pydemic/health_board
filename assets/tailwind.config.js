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
        "hb-choropleth-1": { DEFAULT: colors.green[600], dark: colors.green[800] },
        "hb-choropleth-2": { DEFAULT: colors.lime[600], dark: colors.lime[800] },
        "hb-choropleth-3": { DEFAULT: colors.yellow[400], dark: colors.yellow[600] },
        "hb-choropleth-4": { DEFAULT: colors.amber[500], dark: colors.amber[800] },
        "hb-choropleth-5": { DEFAULT: colors.orange[500], dark: colors.orange[800] },
      },
      zIndex: {
        '1000': 1000,
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
