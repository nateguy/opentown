json.array!(@plans) do |plan|
  json.extract! plan, :id, :name, :district
  json.url url_for(@plans, format: :json)
end