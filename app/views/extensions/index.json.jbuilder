json.array!(@extensions) do |extension|
  json.extract! extension, :id
  json.url extension_url(extension, format: :json)
end
