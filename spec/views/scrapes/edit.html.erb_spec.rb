require 'rails_helper'

RSpec.describe "scrapes/edit", type: :view do
  before(:each) do
    @scrape = assign(:scrape, Scrape.create!())
  end

  it "renders the edit scrape form" do
    render

    assert_select "form[action=?][method=?]", scrape_path(@scrape), "post" do
    end
  end
end
