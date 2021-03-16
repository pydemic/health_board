const build_data = (subType, data) => {
  if (subType === "pyramidBar") {
    data.options.scales.xAxes[0].ticks.callback = (v) => v < 0 ? -v : v
    data.options.tooltips.callbacks.label = (c) => {
      let value = Number(c.value)
      value = value < 0 ? -value : value

      let datasetLabel = data.data.datasets[c.datasetIndex].label
      return `${datasetLabel}: ${value}`
    }
  }

  return data
}

const canRender = (charts, id, timestamp) => {
  const chartsData = charts[id]

  if (chartsData) {
    const { chart, previousTimestamp } = chartsData

    if (previousTimestamp < timestamp) {
      chart.destroy()
    } else {
      return false
    }
  }

  return true
}

export const renderChart = (ChartJS, charts, { id, subType, data, timestamp }) => {
  if (canRender(charts, id, timestamp)) {
    const newChart = new ChartJS(`canvas_${id}`, build_data(subType, data))
    charts[id] = { chart: newChart, previousTimestamp: timestamp }
  }
}
