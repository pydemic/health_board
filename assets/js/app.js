import "../css/app.scss"

import "alpinejs"
import ChartJS from 'chart.js'
import L from 'leaflet'

import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

import { renderMap } from "./map_render"
import { renderChart } from "./chart_render"

window.ChartJS = ChartJS
window.L = L

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

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) { window.Alpine.clone(from.__x, to) }
    }
  }
})

window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

liveSocket.connect()

window.liveSocket = liveSocket
