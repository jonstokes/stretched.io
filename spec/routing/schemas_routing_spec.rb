require "rails_helper"

RSpec.describe SchemasController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/schemas").to route_to("schemas#index")
    end

    it "routes to #new" do
      expect(:get => "/schemas/new").to route_to("schemas#new")
    end

    it "routes to #show" do
      expect(:get => "/schemas/1").to route_to("schemas#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/schemas/1/edit").to route_to("schemas#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/schemas").to route_to("schemas#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/schemas/1").to route_to("schemas#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/schemas/1").to route_to("schemas#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/schemas/1").to route_to("schemas#destroy", :id => "1")
    end

  end
end
