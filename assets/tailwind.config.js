const colors = require('tailwindcss/colors')

module.exports = {
  purge: {
    enabled: process.env.MIX_ENV === "prod",
    content: [
      '../lib/**/*.ex',
      '../lib/**/*.leex',
      '../lib/**/*.eex',
      '../lib/**/*.sface',
      './js/**/*.js'
    ]
  },
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'hb-a': { DEFAULT: colors.blueGray[50], dark: colors.blueGray[800] }, // Background
        'hb-aa': { DEFAULT: colors.lightBlue[600], dark: colors.lightBlue[900] }, // Alternative background
        'hb-b': { DEFAULT: colors.trueGray[900], dark: colors.coolGray[400] }, // Text
        'hb-ba': { DEFAULT: colors.blueGray[50], dark: colors.coolGray[400] }, // Alternative text
        'hb-c': { DEFAULT: colors.lightBlue[100], dark: colors.blueGray[700] }, // Common hover
        'hb-ca': { DEFAULT: colors.lightBlue[700], dark: colors.blueGray[700] }, // Alternative hover
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
