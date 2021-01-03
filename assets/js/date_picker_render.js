const serializeForm = (form, meta = {}) => {
  let formData = new FormData(form)
  let toRemove = []

  formData.forEach((val, key, index) => {
    if (val instanceof File) { toRemove.push(key) }
  })

  // Cleanup after building fileData
  toRemove.forEach(key => formData.delete(key))

  let params = new URLSearchParams()
  for (let [key, val] of formData.entries()) { params.append(key, val) }
  for (let metaKey in meta) { params.append(metaKey, meta[metaKey]) }

  return params.toString()
}

export const renderDatePicker = (hook, tail, datePickers, { id, from, to, date }) => {
  if (datePickers[id]) {
    datePickers[id].remove()
  }

  const datePicker = tail(`#${id}`, {
    dateBlacklist: false,
    timeFormat: false,
    locale: "pt_BR",
    dateRanges: [
      {
        start: from,
        end: to,
        days: true
      }
    ]
  })

  if (date) {
    const selectedDate = new Date(date)
    datePicker.selectDate(selectedDate.getUTCFullYear(), selectedDate.getUTCMonth(), selectedDate.getUTCDate())
  }

  datePicker.on("change", () => {
    hook.pushEvent("apply_filter", { _target: [id], date: datePicker.select.toISOString().substring(0, 10) })
  })

  datePickers[id] = datePicker
}
