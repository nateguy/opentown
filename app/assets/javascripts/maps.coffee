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
PolygonCords = {}

$ ->


  newOverlay = null

  initializeMap = ->
    geocoder = new google.maps.Geocoder()

    imageBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(22.294193,113.946973)
      new google.maps.LatLng(22.305817,113.966819))



    latlng = new google.maps.LatLng(22.2670, 114.1880)
    mapOptions =
      center: latlng,
      zoom: 8


    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)


    # map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)


    vertix = $(".vertix")

    for i in vertix
      i = $(i)
      planid = i.data('planid')
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
        editable: true
        paths: PolygonCords[i],
        strokeColor: '#FF0000',
        fillColor: '#FF0000',
        fillOpacity: 0.5,
        id: i,
        name: PolygonCords[i].name

      polygon[i].setMap(map)
      google.maps.event.addListener(polygon[i], 'click', showInfo)
      infoWindow = new google.maps.InfoWindow()

    # myInfoWindow = new google.maps.InfoWindow()
    # DrawingTools()
    planOverlay = new google.maps.GroundOverlay(
      'plan/tungchung_cropped.jpg',
      imageBounds)
    planOverlay.setMap(map)

  DrawingTools = ->
    myDrawingManager = new google.maps.drawing.DrawingManager
      drawingMode: null,
      drawingControl: true,
      drawingControlOptions:
          position: google.maps.ControlPosition.TOP_RIGHT,
          drawingModes: [
              google.maps.drawing.OverlayType.POLYGON
          ]
      ,
      polygonOptions:
          draggable: true,
          editable: true,
          fillColor: '#cccccc',
          fillOpacity: 0.5,
          strokeColor: '#000000'

    myDrawingManager.setMap(map)

    FieldDrawingCompletionListener()



  FieldDrawingCompletionListener = ->

    google.maps.event.addListener(
      myDrawingManager, 'polygoncomplete', (polygon) ->
        myField = polygon
        ShowDrawingTools(false)
        PolygonEditable(false)
        AddPropertyToField()
        FieldClickListener()
    )

  ShowDrawingTools = (val) ->
    myDrawingManager.setOptions
        drawingMode: null,
        drawingControl: val

  AddPropertyToField = ->
    obj =
        'id':5,
        'grower':'Joe',
        'farm':'Dream Farm'
    console.log myField
    myField.objInfo = obj


  FieldClickListener = ->
    google.maps.event.addListener(
      myField, 'click', (event) ->

        message = GetMessage(myField)
        myInfoWindow.setOptions({ content: message })
        myInfoWindow.setPosition(event.latLng)
        myInfoWindow.open(map)
    )



  GetMessage = (polygon) ->
    coordinates = polygon.getPath().getArray()
    message = ''

    if typeof myField != undefined
      message += '<h1 style="color:#000">Grower: ' + myField.objInfo.grower + '<br>' + 'Farm: ' + myField.objInfo.farm + '</h1>'

    message += '<div style="color:#000">This polygon has ' + coordinates.length + '</div>'

    coordinateMessage = '<p style="color:#000">My coordinates are:<br>'
    for i in [0..(coordinates.length - 1)]
      coordinateMessage += coordinates[i].lat() + ', ' + coordinates[i].lng() + '<br>'

    coordinateMessage += '</p>'

    message += '<p><button onclick=idFunction()>Edit</button> ' + '<a href="#" onclick="PolygonEditable(false)">Done</a> ' + '<a href="#" onclick="DeleteField(myField)">Delete</a></p>' + coordinateMessage

    return message

  showNewPoly = (event) ->
    console.log "rectangle moved"

  showInfo = (event) ->

    # console.log event



    infoWindow.setContent("<a href='plan/#{this.id}'>#{this.name}</a>")
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)
    console.log this.getPath().getArray()


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

  $("#print_polygon").click ->
    alert "hey"
    console.log polygon

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