require "rails_helper"

RSpec.describe AdaptersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/adapters").to route_to("adapters#index")
    end

    it "routes to #new" do
      expect(:get => "/adapters/new").to route_to("adapters#new")
    end

    it "routes to #show" do
      expect(:get => "/adapters/1").to route_to("adapters#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/adapters/1/edit").to route_to("adapters#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/adapters").to route_to("adapters#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/adapters/1").to route_to("adapters#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/adapters/1").to route_to("adapters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/adapters/1").to route_to("adapters#destroy", :id => "1")
    end

  end
end
