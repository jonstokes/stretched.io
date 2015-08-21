require 'rails_helper'

RSpec.describe "RateLimits", type: :request do
  describe "GET /rate_limits" do
    it "works! (now write some real specs)" do
      get rate_limits_path
      expect(response).to have_http_status(200)
    end
  end
end
