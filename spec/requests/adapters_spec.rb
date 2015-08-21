require 'rails_helper'

RSpec.describe "Adapters", type: :request do
  describe "GET /adapters" do
    it "works! (now write some real specs)" do
      get adapters_path
      expect(response).to have_http_status(200)
    end
  end
end
