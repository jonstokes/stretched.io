require 'spec_helper'

describe ExtractDocumentFromNode::RunJsonSetters do
  let(:title)    { "PAGE 1" }
  let(:domain)   { "www.retailer.com" }
  let(:instance) { { 'price' => 100 } }
  let(:page)     { create(:page, domain: domain, title: title) }
  let(:adapter)  { create(:document_adapter, domain: domain) }
  let(:reader)   { create(:session_reader, document_adapter: adapter)}
  let(:node)     { page.doc.at_xpath("//html") }

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = ExtractDocumentFromNode::RunJsonSetters.call(
        node:     node,
        page:     page,
        instance: instance,
        reader:   reader
      )

      expect(instance['title']).to eq(title)
      expect(instance['price']).to eq(100) # decoy
    end
  end
end
