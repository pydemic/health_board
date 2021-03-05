export const createInfoControl = (L, suffix, searchParams) => {
  let info = L.control()

  info.onAdd = () => {
    info._infoDiv = L.DomUtil.create("div", "bg-hb-a dark:bg-hb-a-dark text-hb-b dark:text-hb-b-dark flex flex-col place-content-evenly self-center border rounded-lg border-opacity-20 border-hb-ca dark:border-hb-ca-dark")
    return info._infoDiv
  }

  info.update = (feature) => {
    if (feature != null && feature !== undefined) {
      const { id, name, group, value } = feature.properties

      searchParams.set("location", id)

      L.DomUtil.removeClass(info._infoDiv, "hidden")
      info._infoDiv.innerHTML = `
          <div class="px-5 py-2 font-bold text-center">
            <a href="${window.location.pathname}?${searchParams.toString()}" target="_blank" class="text-hb-b dark:text-hb-b-dark hover:underline focus:outline-none focus:underline">
              ${name}
            </a>
          </div>
          <div class="flex-grow px-5 py-2 text-center border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">
            <span class="bg-hb-choropleth-${group} dark:bg-hb-choropleth-${group}-dark inline-flex items-center px-2 py-1 text-xs rounded-full">
              ${value}
            </span>
          </div>
        ` + (suffix ? `<div class="px-5 py-2 border-t border-opacity-20 border-hb-ca dark:border-hb-ca-dark">${suffix}</div>` : "")

    } else {
      L.DomUtil.addClass(info._infoDiv, "hidden")
      info._infoDiv.innerHTML = ""
    }
  }

  return info
}

export const fetchGeoJson = (L, map, info, geojson) => {
  var group;

  const geoJsonStyle = (feature) => {
    const group = feature.properties.group

    return {
      weight: 1,
      opacity: 1,
      dashArray: "3",
      fillOpacity: 0.7,
      className: `fill-current stroke-current text-hb-choropleth-${group} dark:text-hb-choropleth-${group}-dark`
    }
  }

  const highlightFeature = (e) => {
    let layer = e.target

    layer.setStyle({
      weight: 2,
      dashArray: ""
    })

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
      layer.bringToFront()
    }

    info.update(layer.feature)
  }

  const resetHighlight = (e) => {
    group.resetStyle(e.target)
  }

  const zoomToFeature = (e) => {
    map.fitBounds(e.target.getBounds());
  }

  if (geojson.features.length <= 1000) {
    const onEachFeature = (feature, layer) => {
      layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
      })
    }

    map.on("mouseout", () => info.update())

    group = L.geoJson(geojson, { style: geoJsonStyle, onEachFeature: onEachFeature })
  } else {
    group = L.geoJson(geojson, { style: geoJsonStyle })
  }
  map.fitBounds(group.getBounds())

  return group
}

export const removePreviousMap = (maps, id) => {
  try {
    const map = maps[id]
    if (map && 'remove' in map) {
      map.off()
      map.remove()
      delete (maps[id])
    }
  } catch (error) {
    console.error(error)
  }
}
