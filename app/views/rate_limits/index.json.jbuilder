json.array!(@rate_limits) do |rate_limit|
  json.extract! rate_limit, :id
  json.url rate_limit_url(rate_limit, format: :json)
end
