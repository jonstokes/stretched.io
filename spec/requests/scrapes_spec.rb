require 'rails_helper'

RSpec.describe "Scrapes", type: :request do
  describe "GET /scrapes" do
    it "works! (now write some real specs)" do
      get scrapes_path
      expect(response).to have_http_status(200)
    end
  end
end
