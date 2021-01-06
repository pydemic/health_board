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

export const renderChart = (ChartJS, charts, { id, subType, data }) => {
  console.log(id)
  if (charts[id]) {
    charts[id].destroy()
  }

  charts[id] = new ChartJS(id, build_data(subType, data))
}
