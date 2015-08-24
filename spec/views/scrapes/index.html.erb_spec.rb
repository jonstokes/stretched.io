require 'rails_helper'

RSpec.describe "scrapes/index", type: :view do
  before(:each) do
    assign(:scrapes, [
      Scrape.create!(),
      Scrape.create!()
    ])
  end

  it "renders a list of scrapes" do
    render
  end
end
