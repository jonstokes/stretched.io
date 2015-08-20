require 'spec_helper'
require 'webmock/rspec'

describe RunSession do
  let(:feed_id) { SecureRandom.uuid }
  let!(:schema) {
    create(
      :schema,
      data: {
        "type" => "object",
        "$schema" => "http://json-schema.org/draft-04/schema",
        "properties" => {
          "title" => { "type" => "string" },
          "price" => { "type" => "string" },
          "stock" => { "type" => "string" }
        },
        "required" => ["title", "price"]
      }
    )
  }
  let!(:adapter) {
    create(
      :adapter,
      schema: schema,
      script_names: [],
      property_setters: {
        title: [{find_by_xpath: {xpath: "//title"}}],
        price: [{find_by_xpath: {xpath: "//div[@id='price']"}}],
        stock: [{
          find_by_xpath: {
            xpath:   "//div[@id='stock']",
            label:   "in_stock"
          }
        }]
      }
    )
  }
  let(:page_attributes) {{
    body: <<-EOS
      <html>
        <header>
          <title>Page Title</title>
        </header>
        <body>
          <div id="price">100</div>
          <div id="stock">In Stock</div>
        </body>
      </html>
    EOS
  }}
  let(:source) { create(:sunbro_page, page_attributes) }
  let!(:pages)  {
    5.times.map { |n|
      create(
        :page,
        page_attributes.merge(
          url:        "http://www.retailer.com/#{n}",
          source:     source,
          feed_id:    feed_id,
          fetched_at: nil
        )
      )
    }
  }
  let!(:feed) {
    create(:feed, id: feed_id, adapters: [adapter], urls: pages.map {|p| {url: p.url} })
  }
  let(:timer)  { Bellbro::Timer.new }

  before :each do
    feed.clear_redis
    refresh_index
    pages.each do |page|
      stub_request(:get, page.url).
        to_return {
          {
            body:    page.body,
            status:  page.code,
            headers: page.headers
          }
        }
    end
  end

  describe "#call" do
    it "runs a feed session and extracts JSON objects from pages" do
      feed.start
      refresh_index
      RunSession.call(timer: timer, feed: feed)
      feed.stop
      refresh_index

      feed = Feed.all.first
      expect(feed.sessions.count).to eq(1)
      expect(Document.count).to eq(Page.count)

      Document.all.each do |document|
        expect(document.properties['title']).to eq("Page Title")
      end

      Page.all.each do |page|
        expect(page.fetched_at).not_to be_nil
      end
    end

    it "times out when the timer is up" do
      pending "Example"
      expect(true).to eq(false)
    end
  end
end
