require 'rails_helper'

RSpec.describe "scrapes/new", type: :view do
  before(:each) do
    assign(:scrape, Scrape.new())
  end

  it "renders new scrape form" do
    render

    assert_select "form[action=?][method=?]", scrapes_path, "post" do
    end
  end
end
