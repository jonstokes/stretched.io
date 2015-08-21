json.array!(@feeds) do |feed|
  json.extract! feed, :id, :Schema, :Adapter
  json.url feed_url(feed, format: :json)
end
