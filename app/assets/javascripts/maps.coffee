geocoder = null
map = null
infoWindow = null

                 #holds the map object drawn on the
myDrawingManager = null      # holds drawing tools
myField = null               # holds the polygon we draw using drawing tools
myInfoWindow = null          #when our polygon is clicked, a dialog box
centerpoint = null
# overlay = null
polygon = []
polygonVertices = {}
zones = {}

$ ->


  newOverlay = null
  zones = zoneTypes()




  initializeMap = ->

    geocoder = new google.maps.Geocoder()
    imageBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(22.294193,113.946973)
      new google.maps.LatLng(22.305817,113.966819))
    latlng = new google.maps.LatLng(22.297256, 113.948430)
    mapOptions =
      center: latlng,
      zoom: 15


    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)


    # map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    if $("body.plans.show").length

      planid = $(".plan_id").data('planid')

      loadAllZones(planid)

    if $("body.plans.userplan").length

      planid = $(".plan_id").data('planid')
      console.log "body plans userplan " + planid
      customPolygons = loadCustomPolygons(planid)
      console.log customPolygons
      loadAllZones(planid, customPolygons)

    if $("body.home").length
      loadPlansOnly()

  loadCustomPolygons = (planid) ->
    customPolygons = {}
    for userpolygon in $(".user_polygon")
      polygonid = $(userpolygon).data('polygon')

      customPolygons[polygonid] = {}
      customPolygons[polygonid].zoneid = $(userpolygon).data('zone')
      customPolygons[polygonid].description = $(userpolygon).data('description')
    customPolygons
    #     customPolygons[polygonid].description = data[i].custom_description
    # customPolygons = {}

    # response = $.ajax(
    #   url: '/plans/userplan/' + planid
    #   dataType: 'json'
    # )

    # response.done (data) ->

    #   console.log data
    #   for i of data
    #     polygonid = data[i].polygon_id
    #     customPolygons[polygonid] = {}
    #     customPolygons[polygonid].zone_id = data[i].custom_zone
    #     customPolygons[polygonid].description = data[i].custom_description
    #   console.log "returning custom polygons"
    # customPolygons

  loadPlansOnly = ->
    response = $.ajax(
      url: 'home'
      dataType: 'json'
    )

    response.done (data) ->

      for i of data
        planid = data[i].id
        name = data[i].name
        vertices = []
        for polygon in data[i].polygons
          polygonid = polygon.id
          if polygon.polygontype == "planmap"
            for vertex in polygon.vertices
              vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)
          polygon = new google.maps.Polygon
            editable: false,
            paths: vertices,
            strokeWeight: 0.5,
            fillColor: '#888888',
            fillOpacity: 1,
            id: polygonid,
            planid: planid,
            name: name

          polygon.setMap(map)
          google.maps.event.addListener(polygon, 'click', showInfo)
          infoWindow = new google.maps.InfoWindow()



  loadAllZones = (planid, customPolygons) ->

    response = $.ajax(
      url: '/plans/' + planid
      dataType: 'json'
      )

    response.done (data) ->
      console.log data
      for polygon in data.polygons
        vertices = []
        console.log "before custom polygon decider"
        console.log customPolygons
        if customPolygons? and customPolygons[polygon.id]?

          zoneid = customPolygons[polygon.id].zoneid
          description = customPolygons[polygon.id].description
        else

          zoneid = polygon.zone_id
          description = polygon.description


        for vertex in polygon.vertices
          vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)

        polygon = new google.maps.Polygon
          editable: false
          paths: vertices,
          strokeWeight: 0.5,
          fillColor: zones[zoneid].color_code,
          fillOpacity: 1,
          id: polygon.id,
          description: description
        console.log "polygon " + polygon.id
        polygon.setMap(map)

        google.maps.event.addListener(polygon, 'click', showZoneInfo)
        infoWindow = new google.maps.InfoWindow()



  showInfo = (event) ->

    # console.log event
    console.log this.id
    id = this.id
    planid = this.planid
    name = this.name

    paths = this.getPath().getArray()

    google.maps.event.addListener(infoWindow, 'domready', ->
      $('#modify').click ->
        alert "hey"
        console.log id
        )

    content = "<a href='plans/#{planid}'>#{name}</a> #{id}"
    content_end = "<br><form id='modifypolygon' action='plans/modifypolygon' method='post'>
    <input type='hidden' name='id' value='#{id}'>
    <input type='hidden' name='paths' value=' " + paths + " '><button>Submit</button><br>
    <a id='modify'>Modify</a>"
    infoWindow.setContent(content)
        # infoWindow.setContent(content + content_end)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

  showZoneInfo = (event) ->


    id = this.id
    planid = this.planid
    name = this.name
    description = this.description
    paths = this.getPath().getArray()
    console.log this
    selectbox = ""
    for id of zones
      selectbox += "<option value=#{id}>#{zones[id].description}</option>"


    changeform = "Change this zone: <form action='/plans/userplan/newzone/' method='post'>Polygon:
    <input type='text' value='#{this.id}' name='polygonid'>
      <br>Change to: <select name='zoneid'>" + selectbox + "</select><br>

      <input type='submit' value='submit'></form>"
    if $("body.plans.userplan").length
      infoWindow.setContent(description + "<br>" + changeform)
    else
      infoWindow.setContent(description)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  # PlanOverlay.prototype = new google.maps.OverlayView()
  google.maps.event.addDomListener(window, 'load', initializeMap)

  $('.btn').click ->
    $(this).parent().find('.active').removeClass('active')
    $(this).addClass('active')



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

zoneTypes = ->


  response = $.ajax(
    url: '/zones'
    dataType: 'json'
  )

  response.done (data) ->
    console.log data

    for i of data

      console.log data[i].id
      id = data[i].id
      code = data[i].code
      description = data[i].description
      classification = data[i].classification
      color_code = data[i].color_code

      zones[id] = { code: code, description: description, classification: classification, color_code: color_code}

  zones


PolygonEditable = (val) ->
    myField.setOptions
        editable: val,
        draggable: val
    myInfoWindow.close()
    return false




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