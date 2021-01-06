const createInfoControl = (L, map, data) => {
  let info = L.control()

  info.onAdd = (map) => {
    info._infoDiv = L.DomUtil.create("div", "uk-card uk-card-default")
    return info._infoDiv
  }

  info.update = (id) => {
    if (id != null && id !== undefined) {
      let item = data.find(item => item.id == id)

      if (item !== null && item !== undefined) {
        L.DomUtil.removeClass(info._infoDiv, "hb-hide")
        info._infoDiv.innerHTML = `
          <div class="uk-card-header">
            <h3 class="uk-card-title">
              ${item.label}
            </h3>
            <span class="uk-label hb-choropleth-${item.group}">${item.value}</span>
          </div>
        `
      }
    } else {
      L.DomUtil.addClass(info._infoDiv, "hb-hide")
      info._infoDiv.innerHTML = ""
    }
  }

  return info
}

const fetchGeoJson = (L, map, info, data, geojson) => {
  var group;

  const geoJsonStyle = (feature) => {
    let item = data.find(item => item.id == feature.id)

    return {
      fillColor: item !== undefined && item !== null ? item.color : "#AAAAAA",
      weight: 1,
      opacity: 1,
      color: item !== undefined && item !== null ? item.color : "#AAAAAA",
      dashArray: "3",
      fillOpacity: 0.7
    }
  }

  const highlightFeature = (e) => {
    let layer = e.target

    layer.setStyle({
      weight: 2,
      color: "black",
      dashArray: "",
      fillOpacity: 0.7
    })

    if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
      layer.bringToFront()
    }

    info.update(layer.feature.id)
  }

  const resetHighlight = (e) => {
    group.resetStyle(e.target)
    info.update()
  }

  const zoomToFeature = (e) => {
    map.fitBounds(e.target.getBounds());
  }

  const onEachFeature = (feature, layer) => {
    layer.on({
      mouseover: highlightFeature,
      mouseout: resetHighlight,
      click: zoomToFeature
    })
  }


  group = L.geoJson(geojson, { style: geoJsonStyle, onEachFeature: onEachFeature })

  map.fitBounds(group.getBounds())

  return group
}

export const renderMap = (L, maps, { id, data, geojson_path, tile_layer_url }) => {
  fetch(geojson_path).then((geojson) => geojson.json()).then((geojson) => {
    if (maps[id]) {
      maps[id].off()
      maps[id].remove()
      delete (maps[id])
    }

    let map = L.map(id, { scrollWheelZoom: false })

    let info = createInfoControl(L, map, data).addTo(map)
    fetchGeoJson(L, map, info, data, geojson).addTo(map)
    L.tileLayer(tile_layer_url, { id: "mapbox/light-v9", maxZoom: 18, tileSize: 512, zoomOffset: -1 }).addTo(map)

    maps[id] = map
  })
}
