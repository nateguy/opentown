json.extract! @plan, :id, :name, :district, :content, :overlay, :sw_lat, :sw_lng, :ne_lat, :ne_lng

json.polygons @plan.polygons, :id, :polygontype, :zone_id, :description, :vertices