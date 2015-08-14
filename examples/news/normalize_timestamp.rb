Script.define "global/normalize_timestamp" do
  extensions 'global/*'

  script do
    timestamp do |instance|
      normalize_time(instance['timestamp'])
    end
  end
end
