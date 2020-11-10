import "../css/app.scss"

import UIkit from "uikit"

window.UIkit = UIkit

import ChartJS from 'chart.js'

window.ChartJS = ChartJS

import L from 'leaflet'

window.L = L

import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

Hooks.Chart = {
  mounted() {
    this.handleEvent("chart_data", ({ id, data }) => new ChartJS(id, data))
  }
}

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

liveSocket.connect()

window.liveSocket = liveSocket
