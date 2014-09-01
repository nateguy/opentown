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
lastZone = null

$ ->


  newOverlay = null
  zones = zoneTypes()




  initializeMap = ->

    geocoder = new google.maps.Geocoder()
    imageBounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(22.294193,113.946973)
      new google.maps.LatLng(22.305817,113.966819))
    # latlng = new google.maps.LatLng(22.297256, 113.948430)
    # mapOptions =
    #   center: latlng,
    #   zoom: 15


    # if $("body.plans.edit").length
    #   planid = $(".plan_id").data('planid')

    #   zoneEditor()


    if $("body.plans.edit").length
      planid = $(".plan_id").data('planid')
      console.log "edit"

      DrawZonesTest(planid)


    if $("body.plans.show").length
      console.log "show"

      planid = $(".plan_id").data('planid')
      loadAllZones(planid)

    if $("body.plans.userplan").length
      console.log "userplan"

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


  loadPlansOnly = ->
    response = $.ajax(
      url: 'home'
      dataType: 'json'
    )

    response.done (data) ->
      latlng = new google.maps.LatLng(22.297256, 113.948430)
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      for i of data
        planid = data[i].id
        name = data[i].name
        vertices = []
        center = centerMap(data[i].polygons)

        for polygon in data[i].polygons
          polygonid = polygon.id
          if polygon.polygontype == "planmap"
            for vertex in polygon.vertices
              vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)

          marker = new google.maps.Marker
            position: new google.maps.LatLng(center[0], center[1])
            map: map
            id: polygonid
            planid: planid
            name: name

          polygon = new google.maps.Polygon
            editable: false
            paths: vertices
            strokeWeight: 0.5
            fillColor: '#ffff00'
            fillOpacity: 0.5
            id: polygonid
            planid: planid
            name: name

          marker.setMap(map)
          polygon.setMap(map)
          google.maps.event.addListener(polygon, 'click', showInfo)
          google.maps.event.addListener(marker, 'click', showInfo)
          infoWindow = new google.maps.InfoWindow()

  showInfo = (event) ->

    id = this.id
    planid = this.planid
    name = this.name

#    paths = this.getPath().getArray()

    google.maps.event.addListener(infoWindow, 'domready', ->
      $('#modify').click ->
        alert "hey"
        console.log id
        )

    content = "<h4><a href='plans/#{planid}'>#{name}</a></h4>"
    # content_end = "<br><form id='modifypolygon' action='plans/modifypolygon' method='post'>
    # <input type='hidden' name='id' value='#{id}'>
    # <input type='hidden' name='paths' value=' " + paths + " '><button>Submit</button><br>
    # <a id='modify'>Modify</a>"
    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  DrawZonesTest = (planid) ->

    response = $.ajax(
      url: '/plans/' + planid
      dataType: 'json'
      )

    response.done (data) ->

      center = centerMap(data.polygons)
      latlng = new google.maps.LatLng(center[0], center[1])
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      drawingManager = new google.maps.drawing.DrawingManager(
        drawingMode: google.maps.drawing.OverlayType.MARKER
        drawingControl: true
        drawingControlOptions:
          position: google.maps.ControlPosition.TOP_CENTER
          drawingModes: [
            google.maps.drawing.OverlayType.MARKER,
            google.maps.drawing.OverlayType.CIRCLE,
            google.maps.drawing.OverlayType.POLYGON,
            google.maps.drawing.OverlayType.POLYLINE
          ]

        markerOptions:
          icon: 'images/beachflag.png'

        polygonOptions:
          fillColor: '#ffff00'
          fillOpacity: 1
          strokeWeight: 1
          clickable: true
          editable: true
          planid: planid
          zIndex: 1
      )
      drawingManager.setMap map

      for polygon in data.polygons
        vertices = []
        zoneid = polygon.zone_id

        for vertex in polygon.vertices
          vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)

        polygon = new google.maps.Polygon
          editable: true
          paths: vertices,
          strokeWeight: 0.5,
          fillColor: zones[zoneid].color_code,
          fillOpacity: 0.5,
          id: polygon.id,
          description: polygon.description
          planid: planid
        polygon.setMap(map)
        addDeleteButton(polygon, 'http://i.imgur.com/RUrKV.png')
        google.maps.event.addListener(polygon, 'click', showZoneEdit)
        infoWindow = new google.maps.InfoWindow()


      google.maps.event.addListener drawingManager, "overlaycomplete", (event) ->
        overlayClickListener(event.overlay, planid)
        #$('#vertices').val(event.overlay.getPath().getArray())
        console.log event.overlay.getPath().getArray()

  overlayClickListener = (overlay, planid) ->
    google.maps.event.addListener overlay, "mouseup", (event) ->
        #$('#vertices').val(overlay.getPath().getArray())

        addDeleteButton(overlay, 'http://i.imgur.com/RUrKV.png')
        google.maps.event.addListener(overlay, 'click', showZoneEdit)
        #console.log overlay.getPath().getArray()
        console.log event.latLng
        if google.maps.geometry.poly.isLocationOnEdge(event.latLng, overlay)
          console.log true
        #console.log event.vertex.lng


  addDeleteButton = (polygon, imageUrl) ->
    path = polygon.getPath()
    path["btnDeleteClickHandler"] = {}
    path["btnDeleteImageUrl"] = imageUrl
    google.maps.event.addListener(polygon.getPath(), 'set_at', pointUpdated)
    google.maps.event.addListener(polygon.getPath(), 'insert_at', pointUpdated)

  pointUpdated = (index) ->

    path = this

    if btnDelete? is false

      undoimg = $("img[src$='https://maps.gstatic.com/mapfiles/undo_poly.png']")

      undoimg.parent().css('height', '21px !important')
      undoimg.parent().parent().append('<div style="overflow-x: hidden; overflow-y: hidden; position: absolute; width: 30px; height: 27px; top:21px;">
        <img src="' + path.btnDeleteImageUrl + '" class="deletePoly" style="height:auto; width:auto; position: absolute; left:0;"/>
          </div>')
      btnDelete = getDeleteButton(path.btnDeleteImageUrl)
      btnDelete.hover (->
        $(this).css "left", "-30px"
        false
      ), (->
        $(this).css "left", "0px"
        false
      )
      btnDelete.mousedown ->
        $(this).css "left", "-60px"
        false

    if path.btnDeleteClickHandler
      btnDelete.unbind('click', path.btnDeleteClickHandler)

    path.btnDeleteClickHandler = ->
      path.removeAt(index)
      false

    btnDelete.click(path.btnDeleteClickHandler)

  getDeleteButton = (imageUrl) ->
    console.log "deletebtn" + imageUrl
    $("img[src$='" + imageUrl + "']")

  showZoneEdit = (event) ->

    if event.vertex == undefined
      content = ""
    else
      content = "This is a vertex"


    id = this.id

    #polygon id
    console.log "polygon id " + id
    planid = this.planid
    name = this.name


    if this.description is undefined
      description = ""
    else
      description = this.description
    paths = this.getPath().getArray()
    #console.log id

    content = "<form action='/plans/modifypolygon' method='post'>Polygon Type: <select name='polygontype'><option value='planmap'>Plan</option>
               <option value='zone'>Zone</option></select>
               <br><input name='paths' type='hidden' value='#{paths}'>
               <br><input name='planid' type='text' value='#{planid}'>
               <br><input name='id' type='text' value='#{id}'>
               <br>Zone Type: <select name='zoneid'>" + getZonesSelectBox() + "</select>
               <br>Description: <input name='description' type='text' value='#{description}'>
               <br><input type='submit' value='submit'></form>"
    #console.log event.latLng.lat() + " " + event.latLng.lng()
    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)



  loadAllZones = (planid, customPolygons) ->



    response = $.ajax(
      url: '/plans/' + planid
      dataType: 'json'
      )

    response.done (data) ->

      center = centerMap(data.polygons)
      latlng = new google.maps.LatLng(center[0], center[1])
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)



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

        if $("body.plans.edit").length
          editable = true
        else
          editable = false

        polygon = new google.maps.Polygon
          editable: editable
          paths: vertices,
          strokeWeight: 0.5,
          zoneid: zoneid,
          fillColor: zones[zoneid].color_code,
          fillOpacity: 1,
          id: polygon.id,
          description: description
        console.log "polygon " + polygon.id
        polygon.setMap(map)

        google.maps.event.addListener(polygon, 'click', showZoneInfo)
        infoWindow = new google.maps.InfoWindow()


  getZonesSelectBox = ->
    selectbox = ""
    for id of zones
      selectbox += "<option value=#{id}>#{zones[id].description}</option>"
    selectbox

  showZoneInfo = (event) ->
    console.log "clicked"

    id = this.id

    zoneid = this.zoneid
    planid = this.planid
    name = this.name
    description = this.description
    paths = this.getPath().getArray()
    $(".zone.#{lastZone}").css('background-color','')
    $(".zone.#{lastZone} a").css('color','')
    $(".zone.#{zoneid}").css('background-color','#880000')
    $(".zone.#{zoneid} a").css('color','#ffffff')
    lastZone = zoneid

    heading = "InfoBox"
    content = "<h4>" + description + "</h4>"
    if $("body.plans.userplan").length
      content =+ "<br>Change this zone: <form action='/plans/userplan/newzone/' method='post'>Polygon:
      <input type='text' value='#{this.id}' name='polygonid'>
      <br>Change to: <select name='zoneid'>" + getZonesSelectBox() + "</select><br>
      <input type='submit' value='submit'></form>"

    infoWindow.setContent(heading + content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  # PlanOverlay.prototype = new google.maps.OverlayView()
  google.maps.event.addDomListener(window, 'load', initializeMap)

  $('#plantabs .btn').click ->
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

centerMap = (polygons) ->
  for polygon in polygons

    if polygon.polygontype == "planmap"

      vertices = polygon.vertices
      lats = vertices.map (vertex) ->
        vertex.lat
      lngs = vertices.map (vertex) ->
        vertex.lng
      lats_avg = (lats.reduce (t, s) -> t + s) / lats.length
      lngs_avg = (lngs.reduce (t, s) -> t + s) / lngs.length

  [lats_avg, lngs_avg]

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