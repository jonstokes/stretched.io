json.array!(@scrapes) do |scrape|
  json.extract! scrape, :id
  json.url scrape_url(scrape, format: :json)
end
