require 'rails_helper'

RSpec.describe "scrapes/show", type: :view do
  before(:each) do
    @scrape = assign(:scrape, Scrape.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
