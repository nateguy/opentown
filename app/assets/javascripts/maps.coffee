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

    if $("body.plans.stats").length

      planid = $(".plan_id").data('planid')
      loadAllZones(planid)

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
        zoom: 10
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      for i of data
        planid = data[i].id
        name = data[i].name
        vertices = []
        center = centerMap(data[i].polygons)

        for polygon in data[i].polygons

          if polygon.polygontype == "planmap"
            polygon = drawPolygon(polygon, false, planid)
            polygon.strokeWeight = 2
            polygon.strokeColor = '#ffffff'
            polygon.fillOpacity = 0.8
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

    id = this.id
    planid = this.planid
    name = this.name

    content = "<h4><a href='plans/#{planid}'>#{name}</a></h4>"

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  setEditable = (polygon) ->
    console.log polygon
    polygon.fillOpacity = 0.7
    polygon.editable = false
    google.maps.event.addListener(polygon, 'click', showZoneEdit)
    google.maps.event.addListener(polygon, 'mouseover', ->
      this.setEditable(true)
      )
    google.maps.event.addListener(polygon, 'mouseout', ->
      this.setEditable(false)
      )
    addDeleteButton(polygon, 'http://i.imgur.com/RUrKV.png')



  setNotEditable = (polygon) ->
    polygon.fillOpacity = 1
    polygon.editable = false
    if $("body.plans.stats").length
      google.maps.event.addListener(polygon, 'click', showZoneStats)
    else
      google.maps.event.addListener(polygon, 'click', showZoneInfo)
    #if !$("body.home").length
    #  google.maps.event.addListener(polygon, 'click', showZoneInfo)


  drawPolygon = (polygon, editable, planid, customPolygons) ->
    vertices = []

    zoneid = polygon.zone_id
    description = polygon.description
    polygontype = polygon.polygontype
    if customPolygons? and customPolygons[polygon.id]?

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
    console.log polygontype
    if polygontype == "planmap"
      polygon.zIndex = 1
      console.log "planmap 1"

    else
      polygon.zIndex = 2
      console.log "zone 2"
    console.log polygon
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

            google.maps.drawing.OverlayType.POLYGON,

          ]


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
                  <input name='id' value='#{planid}' type='hidden'>
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
            drawPolygon(polygon, true, planid)
        for polygon in data.polygons
          if polygon.polygontype == "zone"
            drawPolygon(polygon, true, planid)



      else
        infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener drawingManager, "overlaycomplete", (event) ->
        overlayClickListener(event.overlay, planid)


  overlayClickListener = (overlay, planid) ->
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
    console.log "hey"
    console.log event

    console.log this.editable = true

    id = this.id
    description = this.description
    #polygon id

    planid = this.planid
    name = this.name


    if this.description is undefined
      description = ""
    if id is undefined
      id = ""

    paths = this.getPath().getArray()

    content = "<div class='row'>Current Zone:</div><div class='row'>
    <div class='legendbox' style='background-color:" + zones[this.zoneid].color_code + "'></div><h5>" + zones[this.zoneid].classification + "</h5></div>
              <div class='row'>New Zone:</div>
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
              <input name='planid' type='hidden' value='#{planid}'>
              <input name='id' type='hidden' value='#{id}'>
              <input type='hidden' name='zoneid'>
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
      console.log "dropped "
      newzone = e.dataTransfer.getData("text/plain")
      $("input[name='zoneid']").val(newzone)
      $("#infoBoxDrop").html("<div class='legendbox' style='background-color:" + zones[newzone].color_code + "'></div>
        <h5>" + zones[newzone].classification + "</h5>")
      e.preventDefault()
      false
    )




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
        if polygon.polygontype == "planmap"
          if customPolygons? and customPolygons[polygon.id]?
            drawPolygon(polygon, false, planid, customPolygons)
          else
            drawPolygon(polygon, false, planid)

      for polygon in data.polygons
        if polygon.polygontype == "zone"
          if customPolygons? and customPolygons[polygon.id]?
            drawPolygon(polygon, false, planid, customPolygons)
          else
            drawPolygon(polygon, false, planid)


  getZonesSelectBox = ->
    selectbox = ""
    for id of zones
      selectbox += "<option value=#{id}>#{zones[id].description}</option>"
    selectbox


  showZoneStats = (event) ->
    zones
    zones_users = {}
    id = this.id
    zoneid = this.zoneid
    planid = this.planid
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
    planid = this.planid
    name = this.name
    description = this.description
    paths = this.getPath().getArray()
    console.log paths
    console.log id
    $(".zone.#{lastZone}").css('background-color','')
    $(".zone.#{lastZone} a").css('color','')
    $(".zone.#{zoneid}").css('background-color','#880000')
    $(".zone.#{zoneid} a").css('color','#ffffff')
    lastZone = zoneid

    heading = "<h5>Zone:</h5>"
    content = "<div class='legendbox' style='background-color:" + zones[this.zoneid].color_code + "'></div><div class='row'>" + zones[this.zoneid].classification + "</div></div>
    <h5>Description:</h5><div class='row'>" + description + "</div>"

    if $("body.plans.userplan").length
      content = content + "<h5>New Zone:</h5><div class='row'><div id='infoBoxDrop'><h4>Drop Custom Zone here</h4></div></div>
      <h5>New Description:</h5>
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

    if $("body.plans.userplan").length
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

    for i of data

      id = data[i].id
      code = data[i].code
      description = data[i].description
      classification = data[i].classification
      color_code = data[i].color_code

      zones[id] = { code: code, description: description, classification: classification, color_code: color_code}

  zones
