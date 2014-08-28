json.array!(@zones) do |zone|
  json.extract! zone, :id, :code, :description, :classification, :color_code

end