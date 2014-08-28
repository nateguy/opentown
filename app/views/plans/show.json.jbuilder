json.extract! @plan, :id, :name, :district, :content

json.polygons @plan.polygons, :id, :polygontype, :zone_id, :description, :vertices