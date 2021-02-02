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
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
