json.array!(@adapters) do |adapter|
  json.extract! adapter, :id
  json.url adapter_url(adapter, format: :json)
end
