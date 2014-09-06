geocoder = null
map = null
infoWindow = null
myDrawingManager = null      # holds drawing tools
myField = null               # holds the polygon we draw using drawing tools
myInfoWindow = null          #when our polygon is clicked, a dialog box
centerpoint = null
polygon = []
polygonVertices = {}
newOverlay = null
window.overlay = undefined
window.img = ''
rectangle = null
control = null

$ ->

  newOverlay = null
  zones = zoneTypes()
  console.log zones

  initializeMap = ->

    geocoder = new google.maps.Geocoder()

    if $("body.plans.edit").length

      planId = $(".plan_id").data('planid')
      DrawZonesTest(planId)


    if $("body.plans.show").length

      planId = $(".plan_id").data('planid')
      loadAllZones(planId)

    if $("body.plans.userplan").length
      planId = $(".plan_id").data('planid')
      customPolygons = loadCustomPolygons(planId)
      loadAllZones(planId, customPolygons)

    if $("body.plans.stats").length

      planId = $(".plan_id").data('planid')
      loadAllZones(planId)

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
    google.maps.event.addListener map, 'bounds_changed', ->
      $("#plan_sw_lat").val(map.getBounds().getSouthWest().lat())
      $("#plan_sw_lng").val(map.getBounds().getSouthWest().lng())
      $("#plan_ne_lat").val(map.getBounds().getNorthEast().lat())
      $("#plan_ne_lng").val(map.getBounds().getNorthEast().lng())
      $("#new_plan_coordinates").html(map.getCenter().lat() + " " + map.getCenter().lng())


  loadCustomPolygons = (planId) ->
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
        zoom: 10
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      for plan in data
        vertices = []
        center = centerMap(plan.polygons)

        for polygon in planPolygonsOnly(plan.polygons)

          polygon = drawPolygon(polygon, false, plan.id)
          polygon.strokeWeight = 2
          polygon.strokeColor = '#ffffff'
          polygon.fillOpacity = 0.8
          polygon.fillColor = '#888888'
          polygon.planName = plan.name
          marker = new google.maps.Marker
            position: new google.maps.LatLng(center[0], center[1])
            map: map
            planId: plan.id
            planName: plan.name

          marker.setMap(map)
          google.maps.event.addListener(polygon, 'click', showPlanInfo)
          google.maps.event.addListener(marker, 'click', showPlanInfo)

  planPolygonsOnly = (polygons) ->
    planPolygons = polygons.filter (polygon) ->
      polygon.polygontype == "planmap"
    console.log planPolygons
    planPolygons



  showPlanInfo = (event) ->

    planId = this.planId
    planName = this.planName
    content = "<h4><a href='plans/#{planId}'>#{planName}</a></h4>"

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  adminEditPolygon = (polygon) ->
    polygon.fillOpacity = 0.6
    google.maps.event.addListener(polygon, 'click', showZoneEdit)
    google.maps.event.addListener(polygon, 'mouseover', ->
      this.setEditable(true)
      )
    google.maps.event.addListener(polygon, 'mouseout', ->
      this.setEditable(false)
      )
    addDeleteButton(polygon, 'http://i.imgur.com/RUrKV.png')



  drawPolygon = (polygon, editable, planId, customPolygons) ->
    vertices = []

    polygontype = polygon.polygontype
    if customPolygons? and customPolygons[polygon.id]?

      zoneid = customPolygons[polygon.id].zoneid
      description = customPolygons[polygon.id].description
    else
      zoneid = polygon.zone_id
      description = polygon.description

    for vertex in polygon.vertices
      vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)


    polygon = new google.maps.Polygon
      editable: false,
      paths: vertices,
      strokeWeight: 0.5,
      zoneid: zoneid,
      fillColor: zones[zoneid].color_code,
      fillOpacity: 1,
      id: polygon.id,
      description: polygon.description
      planId: planId
      name: polygon.name

    polygon.setMap(map)
    infoWindow = new google.maps.InfoWindow()

    switch
      when $("body.plans.edit").length then adminEditPolygon(polygon)
      when $("body.plans.show").length
        google.maps.event.addListener(polygon, 'click', showZoneInfo)
      when $("body.plans.userplan").length
        google.maps.event.addListener(polygon, 'click', showZoneInfo)
      when $("body.plans.stats").length
        google.maps.event.addListener(polygon, 'click', showZoneStats)

    polygon

  planmap_bounds = (polygons) ->
    maxX = Math.max.apply(Math, polygons.map((val) ->
      val.lat))
    maxX

  drawingTools = (planId) ->
    new google.maps.drawing.DrawingManager(
      drawingMode: google.maps.drawing.OverlayType.POLYGON
      drawingControl: true
      drawingControlOptions:
        position: google.maps.ControlPosition.TOP_CENTER
        drawingModes: [

          google.maps.drawing.OverlayType.POLYGON,

        ]


      polygonOptions:
        fillColor: '#ffff00'
        fillOpacity: 1
        strokeWeight: 1
        clickable: true
        editable: true
        planId: planId
        zIndex: 1
      )

  DrawZonesTest = (planId) ->


    response = $.ajax(
      url: '/plans/' + planId
      dataType: 'json'
      )

    response.done (data) ->


      imageBounds = new google.maps.LatLngBounds(
        new google.maps.LatLng(data.sw_lat,data.sw_lng)
        new google.maps.LatLng(data.ne_lat,data.ne_lng))
      if data.polygons.length > 0

        center = centerMap(data.polygons)
        center_lng = center[1]
        center_lat = center[0]
        #latlng = new google.maps.LatLng(center[0], center[1])
      else
        center_lng = (data.ne_lng + data.sw_lng) / 2
        center_lat = (data.ne_lat + data.sw_lat) / 2

      latlng = new google.maps.LatLng(center_lat,center_lng)
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
      map.fitBounds(imageBounds)
      drawingManager = drawingTools(planId)
      drawingManager.setMap map

      control = drawControl(map, imageBounds)
      window.img = data.overlay
      overlayImage = new Image()
      overlayImage.src = data.overlay

      window.overlay = drawGroundOverlay(map, window.img, imageBounds)

      google.maps.event.addListener(control, 'bounds_changed', boundsChangedHandler)
      google.maps.event.addListener(control, 'rightclick', (e) ->
        height = (data.ne_lat - data.sw_lat)
        width = height * (overlayImage.width / overlayImage.height)

        center_lng = (data.sw_lng + data.ne_lng) / 2
        new_sw_lng = center_lng - (width / 2)
        new_ne_lng = center_lng + (width / 2)

        imageBounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(data.sw_lat,new_sw_lng)
          new google.maps.LatLng(data.ne_lat,new_ne_lng))
        this.bounds = imageBounds
      )

      google.maps.event.addListener(control, 'click', (e) ->
        infoWindow.close()
        infoWindow = new google.maps.InfoWindow()

        resize = "<h5>Set New Image Bounds</h5>"
        content = "<form action='/plans/update_bounds' method='post'>
                  <input name='id' value='#{planId}' type='hidden'>
                  <input name='sw_lat' type='hidden' value='#{this.getBounds().getSouthWest().lat()}'>
                  <input name='sw_lng' type='hidden' value='#{this.getBounds().getSouthWest().lng()}'>
                  <input name='ne_lat' type='hidden' value='#{this.getBounds().getNorthEast().lat()}'>
                  <input name='ne_lng' type='hidden' value='#{this.getBounds().getNorthEast().lng()}'>
                  <input type='submit' value='Save' class='btn btn-default btn-primary'>
                  </form>"
        infoWindow.setContent(resize + content)
        infoWindow.setPosition(e.latLng)
        infoWindow.open(map)
        )


      if data.polygons.length > 0
        for polygon in data.polygons
          if polygon.polygontype == "planmap"
            drawPolygon(polygon, true, planId)
        for polygon in data.polygons
          if polygon.polygontype == "zone"
            drawPolygon(polygon, true, planId)



      else
        infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener drawingManager, "overlaycomplete", (event) ->
        overlayClickListener(event.overlay, planId)


  overlayClickListener = (overlay, planId) ->
    google.maps.event.addListener overlay, "mouseup", (event) ->


        addDeleteButton(overlay, 'http://i.imgur.com/RUrKV.png')
        google.maps.event.addListener(overlay, 'click', showZoneEdit)



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
    $("img[src$='" + imageUrl + "']")

  showZoneEdit = (event) ->

    id = this.id
    description = this.description
    planId = this.planId
    name = this.name

    if this.description is undefined
          description = ""
    if id is undefined
      id = ""
      content = ""
    else
      content = "<div class='row'>Current Zone:</div><div class='row'>
      <div class='legendbox' style='background-color:" + zones[this.zoneid].color_code + "'></div><h5>" + zones[this.zoneid].classification + "</h5></div>"

    paths_object = new Array()
    for path in this.getPath().getArray()
      paths_object.push { 'lat': path.lat(), 'lng': path.lng()}
    paths = JSON.stringify(paths_object)
    console.log paths
    content = content + "<div class='row'>New Zone:</div>
              <div class='row'><div id='infoBoxDrop'><h4>Drop Custom Zone here</h4></div></div>

              <form action='/plans/modifypolygon' method='post'>
              <div class='row'>Polygon Type:</div>
              <div class='row'><div class='radio'>
                <label><input type='radio' name='polygontype' id='radio_planmap' value='planmap'>Plan Layout</label>
              </div>
              <div class='radio'>
                <label><input type='radio' name='polygontype' id='radio_zone' value='zone' checked>Zone</label>
              </div></div>
              <input name='paths' type='hidden' value='#{paths}'>
              <input name='planId' type='hidden' value='#{planId}'>
              <input name='id' type='hidden' value='#{id}'>
              <input type='hidden' name='zoneid' value=0>
              <div class='row'>Description:</div>
              <div class='row'><div class='form-group'>
              <textarea value='#{description}' placeholder='Describe what should go here instead' name='description' rows='2' class='form-control'>
              </textarea></div></div>
              <div class='row' id='form_modify_polygon'><input type='submit' value='submit' class='btn btn-primary btn-sm'></form>
              <form action='/plans/deletepolygon/' method='post'><input name='id' type='hidden' value='#{id}'>
              <input type='submit' value='Delete' class='btn btn-primary btn-sm'>
              </div></form>"
    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

    infoBoxDrop = document.getElementById("infoBoxDrop")
    infoBoxDrop.addEventListener('dragover' , (e) ->
      e.preventDefault()
      false
    )
    infoBoxDrop.addEventListener('drop', (e) ->
      newzone = e.dataTransfer.getData("text/plain")
      $("input[name='zoneid']").val(newzone)
      $("#infoBoxDrop").html("<div class='legendbox' style='background-color:" + zones[newzone].color_code + "'></div>
        <h5>" + zones[newzone].classification + "</h5>")
      e.preventDefault()
      false
    )




  loadAllZones = (planId, customPolygons) ->

    response = $.ajax(
      url: '/plans/' + planId
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
        if polygon.polygontype == "planmap"

          if customPolygons? and customPolygons[polygon.id]?
            drawPolygon(polygon, false, planId, customPolygons)
          else
            drawPolygon(polygon, false, planId)

      for polygon in data.polygons
        if polygon.polygontype == "zone"
          if customPolygons? and customPolygons[polygon.id]?
            drawPolygon(polygon, false, planId, customPolygons)
          else
            drawPolygon(polygon, false, planId)



  showZoneStats = (event) ->
    zones
    zones_users = {}
    id = this.id
    zoneid = this.zoneid
    planId = this.planId
    name = this.name
    description = this.description
    paths = this.getPath().getArray()

    response = $.ajax(
      url: '/plans/user_polygons'
      dataType: 'json'
      )

    response.done (data) ->
      zone_users = []

      for zone of zones
        zone = parseInt(zone)
        zonePolygons = data.filter((polygon) ->
          polygon.custom_zone == zone && polygon.polygon_id == id
          )
        if zonePolygons.length > 0

          zone_users.push {zone_id: zone, size: zonePolygons.length }

      zone_users = zone_users.sort((obj1, obj2) ->
        obj2.size - obj1.size
        )


      content = "<table class='table table-striped'><tr><th>Zone Code</th><th>Users</th></tr>"

      heading = "<h5>Proposed Alternatives</h5>"
      for zone_user in zone_users
        content = content + "<tr><td>#{zones[zone_user.zone_id].code}</td>
        <td>#{zone_user.size}</td></tr>
        </div>"
      foot = "<table>"


      infoWindow.setContent(heading + content + foot)
      infoWindow.setPosition(event.latLng)
      infoWindow.open(map)


  showZoneInfo = (event) ->

    id = this.id
    zoneid = this.zoneid
    planId = this.planId
    name = this.name
    description = this.description
    paths = this.getPath().getArray()

    $(".zone").css('background-color','')
    $(".zone a").css('color','')
    $(".zone.#{zoneid}").css('background-color','#880000')
    $(".zone.#{zoneid} a").css('color','#ffffff')

    content = "<h5>Description:</h5><div class='row'>" + description + "</div>"
    hiddenInput = "<input type='hidden' name='zoneid'><input type='hidden' value='#{this.id}' name='polygonid'>"
    userInput = "<h5>Zone:</h5><div class='legendbox' style='background-color:" + zones[this.zoneid].color_code + "'></div><div class='row'>" + zones[this.zoneid].classification + "</div></div>
      <h5>New Zone:</h5><div class='row'><div id='infoBoxDrop'><h4>Drop Custom Zone here</h4></div></div>
      <h5>New Description:</h5>
      <form action='/plans/userplan/newzone/' method='post'>
      <div class='row'>
        <div class='form-group'><textarea placeholder='Describe what should go here instead' name='description' rows='2' class='form-control'></textarea>
        </div>
      </div>

      <div class='row'><div class='form-group'>
      <input type='submit' class='btn btn-primary btn-sm' value='submit'></form>
      </div></div>"


    if $("body.plans.userplan").length
      content = content + hiddenInput + userInput

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

    if $("body.plans.userplan").length
      infoBoxDrop = document.getElementById("infoBoxDrop")
      infoBoxDrop.addEventListener('dragover' , (e) ->
        e.preventDefault()
        false
      )
      infoBoxDrop.addEventListener('drop', (e) ->

        newzone = e.dataTransfer.getData("text/plain")
        $("input[name='zoneid']").val(newzone)
        $("#infoBoxDrop").html("<div class='legendbox' style='background-color:" + zones[newzone].color_code + "'></div>
          <h5>" + zones[newzone].classification + "</h5>")
        e.preventDefault()
        false
      )


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
    zIndex: 0

drawGroundOverlay = (map, url, bounds) ->
  options =
    opacity: 0.7
    zIndex: 0
  overlay = new google.maps.GroundOverlay(url, bounds, options)
  overlay.setMap(map)
  overlay


addOverlay = ->
  control.setVisible(true)
  window.overlay.setMap(map)

removeOverlay = ->
  control.setVisible(false)
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

  zones = {}
  response = $.ajax(
    url: '/zones'
    dataType: 'json'
  )

  response.done (data) ->
    console.log "zone types"
    console.log data

    for zone in data

      id = zone.id
      code = zone.code
      description = zone.description
      classification = zone.classification
      color_code = zone.color_code

      zones[id] = { code: code, description: description, classification: classification, color_code: color_code}
  zones
