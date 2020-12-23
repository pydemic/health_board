import "../css/app.scss"

import ChartJS from 'chart.js'
import L from 'leaflet'
import UIkit from "uikit"
import Icons from "uikit/dist/js/uikit-icons"

import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"
import datetime from "tail.datetime/js/tail.datetime-full.min.js"

import { renderMap } from "./map_render"
import { renderChart } from "./chart_render"
import { renderDatePicker } from "./date_picker_render"

window.UIkit = UIkit
window.UIkit.use(Icons)

window.ChartJS = ChartJS
window.datetime = datetime

window.L = L
window.MathJax = { MathML: { extensions: ["mml3.js", "content-mathml.js"] } }

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
let maps = {}
let charts = {}

Hooks.Chart = {
  mounted() {
    this.handleEvent("chart_data", (data) => renderChart(ChartJS, charts, data))
  }
}

Hooks.Map = {
  mounted() {
    this.handleEvent("map_data", (data) => renderMap(L, maps, data))
  }
}

renderDatePicker(datetime)

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

liveSocket.connect()

window.liveSocket = liveSocket

