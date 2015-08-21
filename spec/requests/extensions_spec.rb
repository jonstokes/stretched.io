require 'rails_helper'

RSpec.describe "Extensions", type: :request do
  describe "GET /extensions" do
    it "works! (now write some real specs)" do
      get extensions_path
      expect(response).to have_http_status(200)
    end
  end
end
