import * as Utils from "./map_render_utils"

const fetchSearchParams = () => {
  if ('URLSearchParams' in window) {
    return new URLSearchParams(window.location.search)
  } else {
    return null
  }
}

export const renderMap = (L, maps, { id, suffix, geojson }) => {
  fetch(`/api/geojson/${geojson}`).then(result => result.json()).then(geojson => {
    Utils.removePreviousMap(maps, id)

    const map = L.map(id, { scrollWheelZoom: false })
    const searchParams = fetchSearchParams()
    const info = Utils.createInfoControl(L, suffix, searchParams).addTo(map)

    Utils.fetchGeoJson(L, map, info, geojson).addTo(map)

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '<a href="http://osm.org/copyright">OpenStreetMap</a>',
    }).addTo(map)

    maps[id] = map
  }).catch(error => console.error(error))
}
