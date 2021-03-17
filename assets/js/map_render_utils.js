export const createInfoControl = (L, suffix, searchParams) => {
  let info = L.control()

  info.onAdd = () => {
    info._infoDiv = L.DomUtil.create("div")
    info._clicked = false
    info._clickedLayer = null
    L.DomEvent.disableClickPropagation(info._infoDiv)
    info.update()
    return info._infoDiv
  }

  info.update = (feature) => {
    if (!info._clicked && feature != null && feature !== undefined) {
      const { id, name, group, value } = feature.properties

      searchParams.set("location", id)

      L.DomUtil.setClass(info._infoDiv, `leaflet-control mt-2 mr-2 bg-hb-a dark:bg-hb-a-dark text-hb-b dark:text-hb-b-dark flex flex-col place-content-evenly self-center border rounded-lg border-hb-choropleth-${group} dark:border-hb-choropleth-${group}-dark`)
      info._infoDiv.innerHTML = `
          <div class="px-5 py-2 font-bold text-center">
            <a href="${window.location.pathname}?${searchParams.toString()}" target="_blank" class="text-hb-b dark:text-hb-b-dark hover:underline focus:outline-none focus:underline">
              ${name}
            </a>
          </div>
          <div class="flex-grow px-5 py-2 text-center border-t border-hb-choropleth-${group} dark:border-hb-choropleth-${group}-dark">
            <span class="bg-hb-choropleth-${group} dark:bg-hb-choropleth-${group}-dark inline-flex items-center px-2 py-1 text-xs rounded-full"></span>
            ${value}
          </div>
        ` + (suffix ? `<div class="px-5 py-2 border-t border-hb-choropleth-${group} dark:border-hb-choropleth-${group}-dark">${suffix}</div>` : "")

    } else {
      L.DomUtil.setClass(info._infoDiv, "hidden")
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
    if (!info._clicked) {
      const layer = e.target

      layer.setStyle({
        weight: 2,
        dashArray: ""
      })

      if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        layer.bringToFront()
      }

      info.update(layer.feature)
    }
  }

  const resetHighlight = (e) => {
    if (!info._clicked) {
      info.update()
      group.resetStyle(e.target)
    }
  }

  const zoomToFeature = (e) => {
    const layer = e.target

    if (info._clickedLayer == null || info._clickedLayer.feature.properties.id != layer.feature.properties.id) {
      info._clicked = true

      if (info._clickedLayer != null) {
        group.resetStyle(info._clickedLayer)
      }

      layer.setStyle({
        weight: 4,
        dashArray: "",
      })

      if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
        layer.bringToFront()
      }
    } else {
      group.resetStyle(info._clickedLayer)
      info._clicked = false
    }

    info._clickedLayer = layer

    map.fitBounds(layer.getBounds());
  }

  if (geojson.features.length <= 1000) {
    const onEachFeature = (feature, layer) => {
      layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
      })
    }

    group = L.geoJson(geojson, { style: geoJsonStyle, onEachFeature: onEachFeature })
  } else {
    group = L.geoJson(geojson, { style: geoJsonStyle })
  }

  map.fitBounds(group.getBounds())

  return group
}

export const canRender = (maps, id, timestamp) => {
  try {
    const mapData = maps[id]

    if (mapData) {
      const { map, previousTimestamp } = mapData

      if (previousTimestamp < timestamp) {
        map.off()
        map.remove()
        delete (maps[id])
      } else {
        return false
      }
    }
  } catch (error) {
    console.error(error)
  }

  return true
}
