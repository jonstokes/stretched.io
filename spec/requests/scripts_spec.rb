require 'rails_helper'

RSpec.describe "Scripts", type: :request do
  describe "GET /scripts" do
    it "works! (now write some real specs)" do
      get scripts_path
      expect(response).to have_http_status(200)
    end
  end
end
