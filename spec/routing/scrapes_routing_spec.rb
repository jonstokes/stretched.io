require "rails_helper"

RSpec.describe ScrapesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/scrapes").to route_to("scrapes#index")
    end

    it "routes to #new" do
      expect(:get => "/scrapes/new").to route_to("scrapes#new")
    end

    it "routes to #show" do
      expect(:get => "/scrapes/1").to route_to("scrapes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/scrapes/1/edit").to route_to("scrapes#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/scrapes").to route_to("scrapes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/scrapes/1").to route_to("scrapes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/scrapes/1").to route_to("scrapes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/scrapes/1").to route_to("scrapes#destroy", :id => "1")
    end

  end
end
