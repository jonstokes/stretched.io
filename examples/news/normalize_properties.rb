Script.define "global/normalize_properties" do
  extensions 'global/*'

  script do
    id do |instance|
      schemeless_url(instance['id'])
    end

    timestamp do |instance|
      normalize_time(instance['timestamp'])
    end
  end
end
