geocoder = null
map = null
infoWindow = null
myDrawingManager = null      # holds drawing tools
myField = null               # holds the polygon we draw using drawing tools
myInfoWindow = null          #when our polygon is clicked, a dialog box
centerpoint = null
# overlay = null
polygon = []
polygonVertices = {}
zones = {}
lastZone = null
newOverlay = null
window.overlay = undefined
window.img = ''
rectangle = null
#default_latlng = new google.maps.LatLng(22.294193,113.946973)

$ ->

  newOverlay = null
  zones = zoneTypes()

  initializeMap = ->

    geocoder = new google.maps.Geocoder()

    if $("body.plans.edit").length

      planid = $(".plan_id").data('planid')
      DrawZonesTest(planid)


    if $("body.plans.show").length

      planid = $(".plan_id").data('planid')
      loadAllZones(planid)

    if $("body.plans.userplan").length

      planid = $(".plan_id").data('planid')
      customPolygons = loadCustomPolygons(planid)
      loadAllZones(planid, customPolygons)

    if $("body.home").length
      loadPlansOnly()

    if $("body.plans.new").length
      loadBlankMap()




  loadBlankMap = ->
    latlng = new google.maps.LatLng(22.297256, 113.948430)
    mapOptions =
      center: latlng,
      zoom: 15
    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
    marker = new google.maps.Marker
    google.maps.event.addListener(map, 'bounds_changed', ->
      $("#plan_sw_lat").val(map.getBounds().getSouthWest().lat())
      $("#plan_sw_lng").val(map.getBounds().getSouthWest().lng())
      $("#plan_ne_lat").val(map.getBounds().getNorthEast().lat())
      $("#plan_ne_lng").val(map.getBounds().getNorthEast().lng())

      $("#new_plan_coordinates").html(map.getCenter().lat() + " " + map.getCenter().lng())


      )
        #alert map.getCenter();

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

          if polygon.polygontype == "planmap"
            polygon = drawPolygon(polygon, false, planid)

            marker = new google.maps.Marker
              position: new google.maps.LatLng(center[0], center[1])
              map: map
              id: polygon.id
              planid: planid
              name: name

            marker.setMap(map)
            polygon.name = name
            google.maps.event.addListener(polygon, 'click', showInfo)
            google.maps.event.addListener(marker, 'click', showInfo)


  showInfo = (event) ->
    console.log "shoew"
    id = this.id
    planid = this.planid
    name = this.name

    content = "<h4><a href='plans/#{planid}'>#{name}</a></h4>"

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

  setEditable = (polygon) ->
    console.log "editing"
    polygon.editable = true
    addDeleteButton(polygon, 'http://i.imgur.com/RUrKV.png')
    google.maps.event.addListener(polygon, 'click', showZoneEdit)

  setNotEditable = (polygon) ->
    polygon.editable = false
    if !$("body.home").length
      google.maps.event.addListener(polygon, 'click', showZoneInfo)


  drawPolygon = (polygon, editable, planid, customPolygons) ->
    vertices = []

    zoneid = polygon.zone_id
    console.log zoneid
    description = polygon.description
    if customPolygons? and customPolygons[polygon.id]?
      console.log "there is a custompolygon"
      zoneid = customPolygons[polygon.id].zoneid
      description = customPolygons[polygon.id].description

    for vertex in polygon.vertices
      vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)

    polygon = new google.maps.Polygon
      editable: true
      paths: vertices,
      strokeWeight: 0.5,
      zoneid: zoneid,
      fillColor: zones[zoneid].color_code,
      fillOpacity: 0.5,
      id: polygon.id,
      description: polygon.description
      planid: planid
      name: polygon.name
    polygon.setMap(map)
    infoWindow = new google.maps.InfoWindow()
    if editable is true
      setEditable(polygon)
    else
      setNotEditable(polygon)

    polygon



  DrawZonesTest = (planid) ->

    response = $.ajax(
      url: '/plans/' + planid
      dataType: 'json'
      )

    response.done (data) ->
      console.log "showing data"
      console.log data

      imageBounds = new google.maps.LatLngBounds(
        new google.maps.LatLng(data.sw_lat,data.sw_lng)
        new google.maps.LatLng(data.ne_lat,data.ne_lng))
      if data.polygons.length > 0
        console.log "in polygons"
        center = centerMap(data.polygons)
        center_lng = center[1]
        center_lat = center[0]
        #latlng = new google.maps.LatLng(center[0], center[1])
      else
        center_lng = (data.ne_lng + data.sw_lng) / 2
        center_lat = (data.ne_lat + data.sw_lat) / 2
        console.log "center_lng" + center_lng
        console.log "center_lat" + center_lat

      latlng = new google.maps.LatLng(center_lat,center_lng)
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      drawingManager = new google.maps.drawing.DrawingManager(
        drawingMode: google.maps.drawing.OverlayType.POLYGON
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
      console.log imageBounds

      control = drawControl(map, imageBounds)
      window.img = data.overlay
      overlayImage = new Image()
      overlayImage.src = data.overlay
      overlayImage.width
      overlayImage.height
      window.overlay = drawGroundOverlay(map, window.img, imageBounds)
      console.log window.overlay
      google.maps.event.addListener(control, 'bounds_changed', boundsChangedHandler)
      google.maps.event.addListener(control, 'rightclick', (e) ->

        width = (data.ne_lat - data.sw_lat)
        height = width * (overlayImage.height / overlayImage.width)

        center_lng = (data.sw_lng + data.ne_lng) / 2
        new_sw_lng = center_lng - (height / 2)
        new_ne_lng = center_lng + (height / 2)

        imageBounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(data.sw_lat,new_sw_lng)
          new google.maps.LatLng(data.ne_lat,new_ne_lng))
        this.bounds = imageBounds
      )

      google.maps.event.addListener(control, 'click', (e) ->
        infoWindow.close()
        infoWindow = new google.maps.InfoWindow()

        resize = "<a id='setProportion'>Hey</a>"
        content = "Save new bounds: <form action='/plans/update_bounds' method='post'><input name='sw_lat' type='text' value='#{this.getBounds().getSouthWest().lat()}'>
                  <input name='id' value='#{planid}' type='text'>
                  <input name='sw_lng' type='text' value='#{this.getBounds().getSouthWest().lng()}'>
                  <input name='ne_lat' type='text' value='#{this.getBounds().getNorthEast().lat()}'>
                  <input name='ne_lng' type='text' value='#{this.getBounds().getNorthEast().lng()}'>
                  <input type='submit'></form>"
        infoWindow.setContent(resize + content)
        infoWindow.setPosition(e.latLng)
        infoWindow.open(map)
        )
      # newOverlay = new google.maps.GroundOverlay(
      #   '/plan/tungchung_cropped.jpg',
      #   imageBounds)
      addOverlay()
      #newOverlay.setMap(map)

      if data.polygons.length > 0
        for polygon in data.polygons
          drawPolygon(polygon, true, planid)
      else
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
    description = this.description
    #polygon id
    console.log "polygon id " + id
    planid = this.planid
    name = this.name


    if this.description is undefined
      description = ""
    if id is undefined
      id = ""

    paths = this.getPath().getArray()
    #console.log id

    content = "<form action='/plans/modifypolygon' method='post'>
                <div class='row'>Polygon Type:</div>
                <div class='row'><select name='polygontype'>
                <option value='planmap'>Plan</option>
                <option value='zone'>Zone</option></select></div>
                <input name='paths' type='hidden' value='#{paths}'>
                <input name='planid' type='hidden' value='#{planid}'>
                <input name='id' type='hidden' value='#{id}'>
                <div class='row'>Zone Type:</div>
                <div class='row'><select name='zoneid'>" + getZonesSelectBox() + "</select></div>
                <div class='row'>Description:</div>
                <div class='row'><input name='description' type='text' value='#{description}'></div>
                <div class='row'><input type='submit' value='submit' class='btn btn-primary btn-sm'></div></form>"
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
        if customPolygons? and customPolygons[polygon.id]?
          drawPolygon(polygon, false, planid, customPolygons)
        else
          drawPolygon(polygon, false, planid)


  getZonesSelectBox = ->
    selectbox = ""
    for id of zones
      selectbox += "<option value=#{id}>#{zones[id].description}</option>"
    selectbox

  showZoneInfo = (event) ->


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

    heading = "Information:"
    content = "<h5>" + description + "</h5>"
    if $("body.plans.userplan").length
      content = content + "<div class='row'><div id='infoBoxDrop'><h4>Drop Custom Zone here</h4></div></div>
      <form action='/plans/userplan/newzone/' method='post'>
      <div class='row'>
        <div class='form-group'><textarea placeholder='Describe what should go here instead' name='description' rows='2' class='form-control'></textarea>
        </div>
      </div>
      <input type='hidden' name='zoneid'>
      <input type='hidden' value='#{this.id}' name='polygonid'>
      <div class='row'><div class='form-group'>
      <input type='submit' class='btn btn-primary btn-sm' value='submit'></form>
      </div></div>"

    infoWindow.setContent(heading + content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

    infoBoxDrop = document.getElementById("infoBoxDrop")
    infoBoxDrop.addEventListener('dragover' , (e) ->
      e.preventDefault()
      false
    )
    infoBoxDrop.addEventListener('drop', (e) ->
      console.log "dropped "
      newzone = e.dataTransfer.getData("text/plain")
      $("input[name='zoneid']").val(newzone)
      $("#infoBoxDrop").html("<div class='legendbox' style='background-color:" + zones[newzone].color_code + "'></div>
        <h5>" + zones[newzone].classification + "</h5>")
      e.preventDefault()
      false
    )

    drop = (event) ->
      event.preventDefault()
      console.log "dragged"
      this.innerHTML = "dropped" + e.dataTransfer.getData("text/plain")
      false

  # PlanOverlay.prototype = new google.maps.OverlayView()
  google.maps.event.addDomListener(window, 'load', initializeMap)

  $('#plantabs .btn').click ->
    $(this).parent().find('.active').removeClass('active')
    $(this).addClass('active')

  $("#removeOverlay").click ->
    removeOverlay()

  $("#addOverlay").click ->
    addOverlay()

  $("#lockOverlay").click ->
    addOverlay()

  $("#setProportion").click ->
    alert "hey"

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


boundsChangedHandler = (e) ->
  window.overlay.setMap(null) if window.overlay
  window.overlay = drawGroundOverlay(this.map, window.img, this.getBounds())

drawControl = (map, bounds) ->
  new google.maps.Rectangle
    map: map
    bounds: bounds
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillOpacity: 0.0,
    draggable: true,
    editable: true
    clickable: true

drawGroundOverlay = (map, url, bounds) ->
  options =
    opacity: 0.7
  overlay = new google.maps.GroundOverlay(url, bounds, options)
  overlay.setMap(map)
  overlay

lockOverlay = ->
  console.log window
  window.overlay.editable = false

unlockOverlay = ->
  window.overlay.editable = true
  console.log window

addOverlay = ->
  window.overlay.setMap(map)

removeOverlay = ->
  window.overlay.setMap(null)


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
