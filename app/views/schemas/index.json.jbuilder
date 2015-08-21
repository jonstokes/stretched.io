json.array!(@schemas) do |schema|
  json.extract! schema, :id, :Adapter
  json.url schema_url(schema, format: :json)
end
