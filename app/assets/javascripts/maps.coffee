geocoder = null
map = null
infoWindow = null

$ ->

  initializeMap = ->
    geocoder = new google.maps.Geocoder()



    latlng = new google.maps.LatLng(22.2670, 114.1880)
    mapOptions =
      center: latlng,
      zoom: 8


    polygon = []
    PolygonCords = {}

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

  #define polygons


    vertix = $(".vertix")

    for i in vertix
      i = $(i)
      planid = i.data('planid')
#fix this bug

      lat = i.data('lat')
      lng = i.data('lng')
      console.log planid + " " + lat + " " + lng

      if !(PolygonCords[planid])
        PolygonCords[planid] = [new google.maps.LatLng(lat, lng)]
      else
        PolygonCords[planid].push new google.maps.LatLng(lat, lng)
      #polygonCords.push new google.maps.LatLng(lat, lng)

    for i of PolygonCords
      polygon[i] = new google.maps.Polygon
        paths: PolygonCords[i],
        strokeColor: '#FF0000',
        fillColor: '#FF0000',
        fillOpacity: 0.5

      polygon[i].setMap(map)

      google.maps.event.addListener(polygon[i], 'click', showArrays)
      infoWindow = new google.maps.InfoWindow()


    # polygon = new google.maps.Polygon
    #   paths: polygonCords,
    #   strokeColor: '#FF0000',
    #   fillColor: '#FF0000',
    #   fillOpacity: 0.5

    # polygon.setMap(map)

    # google.maps.event.addListener(polygon, 'click', showArrays)
    # infoWindow = new google.maps.InfoWindow()


  showArrays = (event) ->
    vertices = this.getPath()
    contentstring = 'event.latLng.lat()'
    infoWindow.setContent(contentstring)
    infoWindow.setPosition(event.latLng)
    infoWindow.open(map)

  google.maps.event.addDomListener(window, 'load', initializeMap())

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