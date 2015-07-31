require File.expand_path("../../config/environment", __FILE__)

require "rspec/rails"
require "factory_girl_rails"

ActiveRecord::Migration.maintain_test_schema!

#Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include(FactoryGirl::Syntax::Methods)
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
