require "rails_helper"

RSpec.describe ExtensionsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/extensions").to route_to("extensions#index")
    end

    it "routes to #new" do
      expect(:get => "/extensions/new").to route_to("extensions#new")
    end

    it "routes to #show" do
      expect(:get => "/extensions/1").to route_to("extensions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/extensions/1/edit").to route_to("extensions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/extensions").to route_to("extensions#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/extensions/1").to route_to("extensions#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/extensions/1").to route_to("extensions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/extensions/1").to route_to("extensions#destroy", :id => "1")
    end

  end
end
