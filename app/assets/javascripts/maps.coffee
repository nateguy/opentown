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

$ ->


  newOverlay = null

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

    zones = {}

    for c in $(".zone")
      c = $(c)

      id = c.data('id')

      if !(zones[id])
        zones[id] = {code: c.data('code'), color: c.data('color')}

    # map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
    if $("body.plan.index").length

    #Create polygon vertices
      planid = $(".plan_id").data('planid')



      alert planid
      response = $.ajax(
        url: '/plan/' + planid
        dataType: 'json'
      )

      response.done (data) ->

        polygonVertices = createPolygonVertices(data)
        console.log "return"
        console.log polygonVertices
        for i of polygonVertices
          zoneid = polygonVertices[i].zoneid
          description = polygonVertices[i].description
          console.log polygonVertices[i]
          polygon[i] = new google.maps.Polygon
            editable: false
            paths: polygonVertices[i],
            strokeWeight: 0.5,
            # strokeColor: '#FF0000',
            fillColor: zones[zoneid].color,
            fillOpacity: 1,
            id: i,
            description: description

          polygon[i].setMap(map)
          google.maps.event.addListener(polygon[i], 'click', showZoneInfo)
          infoWindow = new google.maps.InfoWindow()

    if $("body.plan.userplan").length
      planid = $(".plan_id").data('planid')

      customPolygons = {}

      $.ajax(
        url: '/plan/userplan/' + planid
        dataType: 'json'
      ).done (data) ->
        for i of data
          polygonid = data[i].polygon_id
          console.log data[i]
          customPolygons[polygonid] = {}
          customPolygons[polygonid].zoneid = data[i].custom_zone
          customPolygons[polygonid].description = data[i].custom_description
        console.log "custompolygons"
        console.log customPolygons

      response = $.ajax(
        url: '/plan/' + planid
        dataType: 'json'
      )

      response.done (data) ->

        polygonVertices = createPolygonVertices(data)

        for i of polygonVertices
          console.log i
          if customPolygons[i]
            console.log "true"
            zoneid = customPolygons[i].zoneid
          else
            console.log "false"
            zoneid = polygonVertices[i].zoneid
          description = polygonVertices[i].description
          console.log polygonVertices[i]
          polygon[i] = new google.maps.Polygon
            editable: false
            paths: polygonVertices[i],
            strokeWeight: 0.5,
            # strokeColor: '#FF0000',
            fillColor: zones[zoneid].color,
            fillOpacity: 1,
            id: i,
            description: description

          polygon[i].setMap(map)
          google.maps.event.addListener(polygon[i], 'click', customInfo)
          infoWindow = new google.maps.InfoWindow()


    if $("body.home").length
      response = $.ajax(
        url: 'home'
        dataType: 'json'
      )

      response.done (data) ->

        polygonVertices = createPlanVertices(data)

        for i of polygonVertices
          planid = polygonVertices[i].planid
          name = polygonVertices[i].name
          zoneid = polygonVertices[i].zoneid

          polygon[i] = new google.maps.Polygon
            editable: false
            paths: polygonVertices[i],
            strokeWeight: 0.5,
            # strokeColor: '#FF0000',
            fillColor: '#888888',
            fillOpacity: 1,
            id: i
            planid: planid,
            name: name

          polygon[i].setMap(map)
          google.maps.event.addListener(polygon[i], 'click', showInfo)
          infoWindow = new google.maps.InfoWindow()


    # myInfoWindow = new google.maps.InfoWindow()
    # DrawingTools()

    # overlay image
    # planOverlay = new google.maps.GroundOverlay(
    #   'plan/tungchung_cropped.jpg',
    #   imageBounds)
    # planOverlay.setMap(map)


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
    console.log paths

    content = "<a href='plan/#{planid}'>#{name}</a> #{id}"
    content_end = "<br><form id='modifypolygon' action='plan/modifypolygon' method='post'>
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

    google.maps.event.addListener(infoWindow, 'domready', ->
      $('#modify').click ->
        alert "hey"
        console.log id
        )
    console.log paths

    content = "this: " + description

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

  customInfo = (event) ->

    id = this.id
    planid = this.planid
    polygonid = this.polygonid
    name = this.name
    description = this.description
    paths = this.getPath().getArray()

    google.maps.event.addListener(infoWindow, 'domready', ->
      $('#modify').click ->
        alert "hey"
        console.log id
        )
    console.log paths

    content = "Change this zone: <form action='/plan/userplan/newzone/' method='post'>Polygon: <input type='text' value='#{id}' name='polygonid'>
      <br>Change to: <input type='text' name='zoneid'><br>
      <input type='submit' value='submit'></form>"
    form = $("#newzoneform").html()
    console.log "polygonid"
    console.log this
    infoWindow.setContent(content)
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

createPlanVertices = (plan) ->
  polygonVertices = {}
  for i of plan

    for polygon in plan[i].polygons
      if polygon.polygontype == "planmap"
        polygonVertices[polygon.id] = []
        polygonVertices[polygon.id].planid = plan[i].id
        polygonVertices[polygon.id].name = plan[i].name


        for vertex in polygon.vertices
          polygonVertices[polygon.id].push new google.maps.LatLng(vertex.lat, vertex.lng)
  polygonVertices

createPolygonVertices = (data) ->
  polygonVertices = {}
  for polygon in data.polygons

    polygonVertices[polygon.id] = []
    polygonVertices[polygon.id].zoneid = polygon.zone_id
    polygonVertices[polygon.id].description = polygon.description
    for vertex in polygon.vertices
      polygonVertices[polygon.id].push new google.maps.LatLng(vertex.lat, vertex.lng)
  console.log polygonVertices
  polygonVertices

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