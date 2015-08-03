require 'spec_helper'

describe RunScriptSetters do
  let(:title)    { "PAGE 1" }
  let(:domain)   { "www.retailer.com" }
  let(:instance) { { 'title' => title } }
  let!(:script)  { create(:script) }
  let(:web_page) { create(:sunbro_page,      domain: domain, title: title) }
  let(:page)     { create(:page,             domain: domain, source: web_page) }
  let(:adapter)  { create(:document_adapter, domain: domain, scripts: [script.name]) }
  let(:node)     { web_page.doc.at_xpath("//html") }

  before(:each) do
    Extension.register_all
  end

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = RunScriptSetters.call(
        instance: instance,
        node:     node,
        page:     page,
        adapter:  adapter
      )

      expect(result.instance['title']).to eq(title.downcase)
    end
  end
end
