json.array!(@scripts) do |script|
  json.extract! script, :id
  json.url script_url(script, format: :json)
end
