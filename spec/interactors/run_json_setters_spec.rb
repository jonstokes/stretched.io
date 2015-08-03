require 'spec_helper'

describe RunJsonSetters do
  let(:title)    { "PAGE 1" }
  let(:domain)   { "www.retailer.com" }
  let(:instance) { { 'price' => 100 } }
  let(:web_page) { create(:sunbro_page,      domain: domain, title: title) }
  let(:page)     { create(:page,             domain: domain, source: web_page) }
  let(:adapter)  { create(:document_adapter, domain: domain) }
  let(:node)     { web_page.doc.at_xpath("//html") }

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = RunJsonSetters.call(
        instance: instance,
        node:     node,
        page:     page,
        adapter:  adapter
      )

      expect(instance['title']).to eq(title)
      expect(instance['price']).to eq(100) # decoy
    end
  end
end
