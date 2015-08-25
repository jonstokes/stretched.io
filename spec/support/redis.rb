RSpec.configure do |config|
  config.before(:each) do
    Index.clear_redis
  end
end