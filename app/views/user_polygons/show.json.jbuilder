json.array! @user_polygons do |user_polygon|
  json.id user_polygon.id
  json.user_id user_polygon.user_id
  json.polygon_id user_polygon.polygon_id
  json.custom_zone user_polygon.custom_zone
  json.custom_description user_polygon.custom_description
end