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
current_polygon = null

$ ->

  newOverlay = null
  zones = zoneTypes()


  initializeMap = ->

    geocoder = new google.maps.Geocoder()

    if $("body.plans.edit").length

      planId = $(".plan_id").data('planid')
      DrawZonesTest(planId)


    if $("body.plans.show").length

      planId = $(".plan_id").data('planid')
      loadAllZones(planId)

    if $("body.user_polygons.show").length

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
      defaultLocation = new google.maps.LatLng(22.297256, 113.948430)

      mapOptions =
        center: defaultLocation
        zoom: 10
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

      if navigator.geolocation
        navigator.geolocation.getCurrentPosition (position) ->
          currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
          map.setCenter(currentLocation)

      for plan in data

        for polygon in planPolygonsOnly(plan.polygons)

          polygon = drawPolygon(polygon, plan.id)
          polygon.strokeWeight = 2
          polygon.strokeColor = '#ffffff'
          polygon.fillOpacity = 0.8
          polygon.fillColor = '#888888'
          polygon.planName = plan.name

          marker = new google.maps.Marker
            position: planmap_bounds(plan.polygons).getCenter()
            map: map
            planId: plan.id
            planName: plan.name

          marker.setMap(map)
          google.maps.event.addListener(marker, 'click', showPlanInfo)





  showPlanInfo = (event) ->

    planId = this.planId
    planName = this.planName
    content = "<h4><a href='plans/#{planId}'>#{planName}</a></h4>"

    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)


  adminEditPolygon = (polygon) ->
    polygon.fillOpacity = 0.6

    google.maps.event.addListener(polygon, 'click', showZone)
    google.maps.event.addListener(polygon, 'rightclick', ->
      if this.editable
        this.setEditable(false)
      else
        this.setEditable(true)
      )

    # google.maps.event.addListener(polygon, 'mouseout', ->
    #   this.setEditable(false)

    #  )
    addDeleteButton(polygon, 'http://i.imgur.com/RUrKV.png')


  drawPlan = (polygon, planId) ->
    vertices = []
    for vertex in polygon.vertices
      vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)

    polygontype = polygon.polygontype
    description = polygon.description
    fillColor = zones[planMapZoneId()].color_code
    polygon = new google.maps.Polygon
      editable: false
      paths: vertices
      strokeWeight: 0.5
      fillColor: fillColor
      fillOpacity: 0.6
      id: polygon.id
      description: description
      planId: planId
      planName: polygon.name


    polygon.setMap(map)

    infoWindow = new google.maps.InfoWindow()

    if $("body.plans.edit").length
      adminEditPolygon(polygon)
    polygon

  drawPolygon = (polygon, planId, customPolygon) ->


    vertices = []

    polygontype = polygon.polygontype
    if customPolygon?
      zoneid = customPolygon.zoneid
      description = customPolygon.description
    else
      zoneid = polygon.zone_id
      description = polygon.description

    for vertex in polygon.vertices
      vertices.push new google.maps.LatLng(vertex.lat, vertex.lng)


    polygon = new google.maps.Polygon
      editable: false
      paths: vertices
      strokeWeight: 0.5
      zoneid: zoneid
      fillColor: zones[zoneid].color_code
      fillOpacity: 1
      id: polygon.id
      description: description
      planId: planId
      name: polygon.name
      polygontype: polygontype

    polygon.setMap(map)


    infoWindow = new google.maps.InfoWindow()

    switch
      when $("body.plans.edit").length then adminEditPolygon(polygon)
      when $("body.plans.show").length
        google.maps.event.addListener(polygon, 'click', showZone)
      when $("body.user_polygons.show").length
        google.maps.event.addListener(polygon, 'click', showZone)
      when $("body.plans.stats").length
        google.maps.event.addListener(polygon, 'click', showZoneStats)
      when $("body.home").length
        google.maps.event.addListener(polygon, 'click', showPlanInfo)
    polygon






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

      latlng = imageBounds.getCenter()
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
        imageBounds = this.getBounds()
        current_ne_lat = imageBounds.getNorthEast().lat()
        current_sw_lat = imageBounds.getSouthWest().lat()
        current_sw_lng = imageBounds.getSouthWest().lng()
        current_ne_lng = imageBounds.getNorthEast().lng()

        height = (current_ne_lat - current_sw_lat)
        width = height * (overlayImage.width / overlayImage.height)

        center_lng = (current_sw_lng + current_ne_lng) / 2
        new_sw_lng = center_lng - (width / 2)
        new_ne_lng = center_lng + (width / 2)

        imageBounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(current_sw_lat,new_sw_lng)
          new google.maps.LatLng(current_ne_lat,new_ne_lng))
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
        for polygon in planPolygonsOnly(data.polygons)
            drawPolygon(polygon, planId)
        for polygon in zonePolygonsOnly(data.polygons)
            drawPolygon(polygon, planId)



      else
        infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener drawingManager, "overlaycomplete", (event) ->
        overlayClickListener(event.overlay, planId)


  overlayClickListener = (overlay, planId) ->
    google.maps.event.addListener overlay, "mouseup", (event) ->


        addDeleteButton(overlay, 'http://i.imgur.com/RUrKV.png')
        google.maps.event.addListener(overlay, 'click', showZone)



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




  loadAllZones = (planId, customPolygons) ->

    response = $.ajax(
      url: '/plans/' + planId
      dataType: 'json'
      )

    response.done (data) ->
      bounds = planmap_bounds(data.polygons)

      latlng = bounds.getCenter()
      mapOptions =
        center: latlng,
        zoom: 15
      map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
      map.fitBounds(bounds)

      for polygon in planPolygonsOnly(data.polygons)
        drawPlan(polygon, planId)


      for polygon in zonePolygonsOnly(data.polygons)
        if customPolygons? && customPolygons[polygon.id]?
          drawPolygon(polygon, planId, customPolygons[polygon.id])
        else
          drawPolygon(polygon, planId)



  showZoneStats = (event) ->

    zones_users = {}
    id = this.id
    zoneid = this.zoneid
    planId = this.planId
    name = this.name
    description = this.description
    paths = this.getPath().getArray()

    response = $.ajax(
      url: '/user_polygons'
      dataType: 'json'
      )

    response.done (data) ->
      zone_users = []

      for zone of zones
        zone = parseInt(zone)
        zonePolygons = data.filter (polygon) ->
          polygon.custom_zone == zone && polygon.polygon_id == id

        if zonePolygons.length > 0
          zone_users.push {zone_id: zone, size: zonePolygons.length }

      zone_users = zone_users.sort (zoneuser1, zoneuser2) ->
        zoneuser2.size - zoneuser1.size


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

  $("input #planmap").click ->
    alert "hey"
    $("#infoBoxDrop").css('display', 'none')

  planMapZoneId = ->
    for id in Object.keys(zones)
      if zones[id]['code'] == "planmap"
        return id

  showZone = (event) ->
    console.log event





    id = this.id
    zoneid = this.zoneid
    planId = this.planId
    name = this.name
    description = this.description

    paths_object = new Array()
    for path in this.getPath().getArray()
      paths_object.push { 'lat': path.lat(), 'lng': path.lng()}
    paths = JSON.stringify(paths_object)


    $(".zone").css('background-color','')
    $(".zone a").css('color','')
    $(".zone.#{zoneid}").css('background-color','#880000')
    $(".zone.#{zoneid} a").css('color','#ffffff')

    # if this.zoneid = planMapZoneId()
    #   polygontype = "planmap"
    # else
    #   polygontype = "zone"

    if this.id?
      id = this.id; description = this.description; zoneid = this.zoneid
      description_tag = "<div class='row'>" + description + "</div>"
      edit_form_tag = "<form action='/polygons/update' method='post'>"

    else
      description = ""; id = ""; description_tag = ""; zoneid = planMapZoneId()
      edit_form_tag = "<form action='/polygons/create' method='post'>"

    header_tag = "<div class='row'><h5>What's this?</h5></div>"
    form_zoneid_tag = "<input type='hidden' name='zoneid' value='#{zoneid}'>"
    # same thing different name
    form_id_tag = "<input type='hidden' value='#{id}' name='id'>"
    form_polygonid_tag = "<input type='hidden' value='#{id}' name='polygonid'>"
    form_polygontype_tag = "<div class='row'>
      <div class='form-group'>

          <input type='radio' name='polygontype' id='planmap' value='planmap'>
          <span>Plan Outline</span>

          <input type='radio' name='polygontype' id='zone' value='zone' checked>
          <span>Zone</span>
      </div></div>"




    form_paths_tag = "<input name='paths' type='hidden' value='#{paths}'>"
    form_planid_tag = "<input name='planId' type='hidden' value='#{planId}'>"

    form_zoneDropBox_tag = "<div class='row'><h5>Set new zone or plan outline and description:</h5></div>
      <div class='row'><div id='infoBoxDrop'><h4>Drop Custom Zone here</h4></div></div>"


    userpolygon_form_tag = "<form action='/user_polygons' method='post'>"
    form_description_tag = "<div class='row'>
        <div class='form-group'><textarea placeholder='Describe what should go here instead' name='description' rows='2' class='form-control'></textarea>
        </div>
      </div>"
    form_submit_tag = "<div class='row' id='form_modify_polygon'>
      <input type='submit' class='btn btn-primary btn-sm' value='submit'></form>"
    form_delete_tag = "<form action='/polygons/delete' method='post'><input name='id' type='hidden' value='#{id}'>
                <input type='submit' value='Delete' class='btn btn-primary btn-sm'>
                </div></form>"


    content = header_tag + description_tag

    if $("body.plans.edit").length
      content = content + form_zoneDropBox_tag + edit_form_tag + form_description_tag + form_paths_tag + form_planid_tag + form_id_tag + form_zoneid_tag + form_submit_tag + form_delete_tag
    if $("body.user_polygons.show").length
      content = content + form_zoneDropBox_tag + userpolygon_form_tag + form_description_tag + form_zoneid_tag + form_polygonid_tag + form_submit_tag + "</div>"
    if $("body.plans.show").length
      content = content



    infoWindow.setContent(content)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

    if $("body.user_polygons.show").length or $("body.plans.edit").length
      infoBoxDrop = document.getElementById("infoBoxDrop")
      infoBoxDrop.addEventListener('dragover' , (e) ->
        e.preventDefault()
        false
      )
      infoBoxDrop.addEventListener('drop', (e) ->

        newzone = e.dataTransfer.getData("text/plain")
        $("input[name='zoneid']").val(newzone)
        $("#infoBoxDrop").html("<div class='zonebox'><div class='legendbox' style='background-color:" + zones[newzone].color_code + "'></div>
          <h5>" + zones[newzone].classification + "</h5></div>")
        e.preventDefault()
        false
      )


  google.maps.event.addDomListener(window, 'load', initializeMap)

  $('#plantabs .btn').click ->
    $(this).parent().find('.active').removeClass('active')
    $(this).addClass('active')
    #initializeMap()

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

  google.maps.Polygon.prototype.getBounds = ->
    bounds = new google.maps.LatLngBounds()
    console.log this.getPath()
    this.getPath().forEach (element,index) ->
      bounds.extend(element)
    bounds

planPolygonId = (zones) ->
  i = zones.filter
    polygontype: "planmap"
  console.log i

planPolygonsOnly = (polygons) ->
  planPolygons = polygons.filter (polygon) ->
    polygon.polygontype == "planmap"

zonePolygonsOnly = (polygons) ->
  planPolygons = polygons.filter (polygon) ->
    polygon.polygontype == "zone"



planmap_bounds = (polygons) ->

  #all_vertices = new Array
  bounds = new google.maps.LatLngBounds()

  for polygon in planPolygonsOnly(polygons)
    for vertex in polygon.vertices
      bounds.extend new google.maps.LatLng(vertex.lat, vertex.lng)

  bounds

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



zoneTypes = ->

  zones = {}
  response = $.ajax(
    url: '/zones'
    dataType: 'json'
  )

  response.done (data) ->

    for zone in data

      id = zone.id
      code = zone.code
      description = zone.description
      classification = zone.classification
      color_code = zone.color_code

      zones[id] = { code: code, description: description, classification: classification, color_code: color_code}

  zones
