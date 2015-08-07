require 'spec_helper'

describe ExtractDocumentFromNode::RunScriptSetters do
  let(:title)    { "PAGE 1" }
  let(:domain)   { "www.retailer.com" }
  let(:instance) { { 'title' => title } }
  let!(:script)  { create(:script) }
  let(:page)     { create(:page,             domain: domain, title: title) }
  let(:adapter)  { create(:document_adapter, domain: domain, scripts: [script.name]) }
  let(:node)     { page.doc.at_xpath("//html") }
  let(:reader)   { create(:session_reader, document_adapter: adapter)}

  before(:each) do
    Extension.register_all
  end

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = ExtractDocumentFromNode::RunScriptSetters.call(
        instance: instance,
        node:     node,
        page:     page,
        reader:   reader
      )

      expect(result.instance['title']).to eq(title.downcase)
    end
  end
end
