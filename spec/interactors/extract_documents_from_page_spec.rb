require 'spec_helper'
require 'webmock/rspec'

describe ExtractDocumentsFromPage do

  let(:domain)  { "www.retailer.com" }
  let(:url)     { "http://#{domain}/products/1" }

  describe "#call" do
    it "adds an empty JSON document for an invalid page" do
      page = create(
        :page,
        url: url,
        body: "<html><head></head><body>Invalid Listing!</body></html>"
      )

      stub_request(:get, page.url.to_s).
        to_return {
          {
            body:    page.body,
            status:  page.code,
            headers: page.headers
          }
        }

      adapter = create(:document_adapter, domain: domain)
      ssn = create(:session, adapter_names: [adapter.name])

      result = ExtractDocumentsFromPage.call(
        page: page,
        ssn:  ssn
      )

      expect(result.documents.size).to eq(1)
      expect(result.documents.first.properties).to eq({})
    end

    it "translates a page into JSON using a JSON adapter" do
      schema = create(
        :document_schema,
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
      adapter = create(
        :document_adapter,
        document_schema: schema,
        property_queries: {
          title: [{find_by_xpath: {xpath: "//title"}}],
          price: [{find_by_xpath: {xpath: "//div[@id='price']"}}],
          stock: [{
            find_by_xpath: {
              xpath:   "//div[@id='stock']",
              label:   "in_stock"
            }
          }],
        }
      )

      page = create(
        :page,
        url: url,
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
      )

      ssn = create(:session, adapter_names: [adapter.name])

      stub_request(:get, page.url.to_s).
        to_return {
          {
            body:    page.body,
            status:  page.code,
            headers: page.headers
          }
        }

      result = ExtractDocumentsFromPage.call(
        page: page,
        ssn:  ssn
      )

      expect(result.documents.size).to eq(1)
      expect(result.documents.first.properties).to eq({
        "title" => "Page Title",
        "price" => "100",
        "stock" => "in_stock"
      })
    end

    it "translates a page into JSON using a script" do
      pending "Example"
      expect(false).to eq(true)
    end

    it "translates a page into JSON using JSON and scripts combined" do
      pending "Example"
      expect(false).to eq(true)
    end

    it "errors if the JSON adapter has an invalid attribute that doesn't match the schema" do
      pending "Example"
      expect {
        ExtractDocumentsFromPage.call(
          page: page,
          ssn: adapter
        )
      }.to raise_error(RuntimeError, "Property listing_type is not defined in schema Listing")
    end

    it "errors if the script has an invalid attribute that doesn't match the schema" do
      pending "Example"
      expect {
        ExtractDocumentsFromPage.call(
          page: page,
          ssn: adapter
        )
      }.to raise_error(RuntimeError, "Property listing_type is not defined in schema Listing")
    end
  end
end
