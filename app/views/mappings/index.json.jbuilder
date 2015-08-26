json.array!(@mappings) do |mapping|
  json.extract! mapping, :id
  json.url mapping_url(mapping, format: :json)
end
