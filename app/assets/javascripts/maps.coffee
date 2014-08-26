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


    # map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    #Create polygon vertices
    vertix = $(".vertex")

    for i in vertix
      i = $(i)
      planid = i.data('planid')
      polygonid = i.data('polygonid')
      planname = i.data('planname')
      lat = i.data('lat')
      lng = i.data('lng')
      console.log planid + " " + lat + " " + lng

      if !(polygonVertices[polygonid])
        polygonVertices[polygonid] = [new google.maps.LatLng(lat, lng)]
        polygonVertices[polygonid].name = i.data('planname')
        polygonVertices[polygonid].planid = i.data('planid')
        polygonVertices[polygonid].zoneid = i.data('zoneid')
      else
        polygonVertices[polygonid].push new google.maps.LatLng(lat, lng)
      #polygonVertices.push new google.maps.LatLng(lat, lng)


    #Create Zones Object
    zones = {}

    for c in $(".zone")
      c = $(c)

      id = c.data('id')
      console.log id
      if !(zones[id])
        zones[id] = {code: c.data('code'), color: c.data('color')}

    #Draw each polygon
    for i of polygonVertices

      zoneid = polygonVertices[i].zoneid

      if $("body.plan").length
        fillcolor = zones[zoneid].color
      else
        fillcolor = '#888888'


      polygon[i] = new google.maps.Polygon
        editable: false
        paths: polygonVertices[i],
        strokeWeight: 0.5,
        # strokeColor: '#FF0000',
        fillColor: fillcolor,
        fillOpacity: 1,
        id: i,
        planid: polygonVertices[i].planid,
        name: polygonVertices[i].name

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

    # FieldDrawingCompletionListener()



  # FieldDrawingCompletionListener = ->

  #   google.maps.event.addListener(
  #     myDrawingManager, 'polygoncomplete', (polygon) ->
  #       myField = polygon
  #       ShowDrawingTools(false)
  #       PolygonEditable(false)
  #       AddPropertyToField()
  #       FieldClickListener()
  #   )

  # ShowDrawingTools = (val) ->
  #   myDrawingManager.setOptions
  #       drawingMode: null,
  #       drawingControl: val

  # AddPropertyToField = ->
  #   obj =
  #       'id':5,
  #       'grower':'Joe',
  #       'farm':'Dream Farm'
  #   console.log myField
  #   myField.objInfo = obj


  # FieldClickListener = ->
  #   google.maps.event.addListener(
  #     myField, 'click', (event) ->

  #       message = GetMessage(myField)
  #       myInfoWindow.setOptions({ content: message })
  #       myInfoWindow.setPosition(event.latLng)
  #       myInfoWindow.open(map)
  #   )



  # GetMessage = (polygon) ->
  #   coordinates = polygon.getPath().getArray()
  #   message = ''

  #   if typeof myField != undefined
  #     message += '<h1 style="color:#000">Grower: ' + myField.objInfo.grower + '<br>' + 'Farm: ' + myField.objInfo.farm + '</h1>'

  #   message += '<div style="color:#000">This polygon has ' + coordinates.length + '</div>'

  #   coordinateMessage = '<p style="color:#000">My coordinates are:<br>'
  #   for i in [0..(coordinates.length - 1)]
  #     coordinateMessage += coordinates[i].lat() + ', ' + coordinates[i].lng() + '<br>'

  #   coordinateMessage += '</p>'

  #   message += '<p><button onclick=idFunction()>Edit</button> ' + '<a href="#" onclick="PolygonEditable(false)">Done</a> ' + '<a href="#" onclick="DeleteField(myField)">Delete</a></p>' + coordinateMessage

  #   return message

  showNewPoly = (event) ->
    console.log "rectangle moved"



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

    # console.log event
    console.log "id of this is: " + this.id
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

    content = "<a href='plan/#{planid}'>#{name}</a>"
    content_end = "<br><form id='modifypolygon' action='plan/modifypolygon' method='post'>
    <input type='hidden' name='id' value='#{id}'>
    <input type='hidden' name='paths' value=' " + paths + " '><button>Submit</button><br>
    <a id='modify'>Modify</a>"
    infoWindow.setContent(content + content_end)
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