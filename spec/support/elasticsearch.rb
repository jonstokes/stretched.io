def refresh_index
  Index.refresh
end

RSpec.configure do |config|
  config.before(:each) do
    Index.create
    Index.refresh
  end

  config.after(:each) do
    Index.delete
  end
end
