require "rails_helper"

RSpec.describe DomainsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/domains").to route_to("domains#index")
    end

    it "routes to #new" do
      expect(:get => "/domains/new").to route_to("domains#new")
    end

    it "routes to #show" do
      expect(:get => "/domains/1").to route_to("domains#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/domains/1/edit").to route_to("domains#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/domains").to route_to("domains#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/domains/1").to route_to("domains#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/domains/1").to route_to("domains#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/domains/1").to route_to("domains#destroy", :id => "1")
    end

  end
end
