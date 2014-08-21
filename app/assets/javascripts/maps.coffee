geocoder = null
map = null
infoWindow = null
# overlay = null

$ ->


  newOverlay = null

  initializeMap = ->
    geocoder = new google.maps.Geocoder()

    imageBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(22.295116,113.9491722)
      new google.maps.LatLng(22.3001587,113.9602229))



    latlng = new google.maps.LatLng(22.2670, 114.1880)
    mapOptions =
      center: latlng,
      zoom: 8


    polygon = []
    PolygonCords = {}

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    newOverlay = new google.maps.GroundOverlay(
      'plan/tungchung_cropped.jpg',
      imageBounds)
    newOverlay.setMap(map)
  #define image overlay
    # swBound = new google.maps.LatLng(22.295116,113.9491722)
    # neBound = new google.maps.LatLng(22.3001587,113.9602229)
    # bounds = new google.maps.LatLngBounds(swBound, neBound)

    # srcImage = 'plan/tungchung_cropped.jpg'

  #define polygons


    vertix = $(".vertix")

    for i in vertix
      i = $(i)
      planid = i.data('planid')
#fix this bug
      planname = i.data('planname')
      lat = i.data('lat')
      lng = i.data('lng')
      console.log planid + " " + lat + " " + lng

      if !(PolygonCords[planid])
        PolygonCords[planid] = [new google.maps.LatLng(lat, lng)]
        PolygonCords[planid].name = i.data('planname')
      else
        PolygonCords[planid].push new google.maps.LatLng(lat, lng)
      #polygonCords.push new google.maps.LatLng(lat, lng)


    for i of PolygonCords
      polygon[i] = new google.maps.Polygon
        paths: PolygonCords[i],
        strokeColor: '#FF0000',
        fillColor: '#FF0000',
        fillOpacity: 0.5,
        id: i,
        name: PolygonCords[i].name

      polygon[i].setMap(map)
#      console.log showInfo

      google.maps.event.addListener(polygon[i], 'click', showInfo)
      infoWindow = new google.maps.InfoWindow()

    # overlay = new PlanOverlay(bounds, srcImage, map)


  showInfo = (event) ->

    # console.log event



    infoWindow.setContent("<a href='plan/#{this.id}'>#{this.name}</a>")
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  showArrays = (event) ->
    vertices = this.getPath()
    console.log this
    console.log event
    contentstring = 'event.latLng.lat()'
    infoWindow.setContent(contentstring)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

  # PlanOverlay.prototype = new google.maps.OverlayView()
  google.maps.event.addDomListener(window, 'load', initializeMap)

  $("#btn_address").click ->
    address = $("#address").val()

    geocoder.geocode
      address: address,
      (results, status) ->
        if status == google.maps.GeocoderStatus.OK

            map.setCenter results[0].geometry.location
            marker = new google.maps.Marker
                map: map,
                position: results[0].geometry.location
        else
            alert "geocode not successful"

#----start --- add on for image overlay

# PlanOverlay = (bounds, image, map) ->

#   this.bounds_ = bounds
#   this.image_ = image
#   this.map_ = map
#   this.div_ = null
#   console.log this
#   this.setMap(map)

# PlanOverlay.prototype.onAdd = ->

#   console.log "add"

#   div = document.createElement('div')
#   div.style.borderStyle = 'none'
#   div.style.borderWidth = '0px'
#   div.style.position = 'absolute'

#   img = document.createElement('img')
#   img.src = this.image_
#   img.style.width = '100%'
#   img.style.height = '100%'
#   img.style.position = 'absolute'
#   div.appendChild(img)

#   this.div_ = div
#   panes = this.getPanes()
#   panes.overlayLayer.appendChild(div)

# PlanOverlay.prototype.draw = ->
#   console.log "draw"
#   overlayProjection = this.getProjection()
#   sw = overlayProjection.fromLatLngToDivPixel(this.bounds_.getSouthWest())
#   ne = overlayProjection.fromLatLngToDivPixel(this.bounds_.getNorthEast())
#   div = this.div_
#   div.style.left = sw.x + 'px'
#   div.style.top = ne.y + 'px'
#   div.style.width = (ne.x - sw.x) + 'px'
#   div.style.height = (sw.y - ne.y) + 'px'

# PlanOverlay.prototype.onRemove = ->
#   this.div_.parentNode.removeChild(this.div_)
#   this.div_ = null

#----end --- add on for image overlay