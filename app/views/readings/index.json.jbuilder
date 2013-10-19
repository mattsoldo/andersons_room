json.array!(@readings) do |reading|
  json.extract! reading, :temp, :recorded_at
  json.url reading_url(reading, format: :json)
end
