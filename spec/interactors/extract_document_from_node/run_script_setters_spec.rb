require 'spec_helper'

describe ExtractDocumentFromNode::RunScriptSetters do
  let(:title)    { "PAGE 1" }
  let(:instance) { ActiveSupport::HashWithIndifferentAccess.new('title' => title) }
  let!(:script)  { create(:script) }
  let(:source)   { create(:sunbro_page, title: title) }
  let(:page)     { create(:page, source: source) }
  let(:adapter)  { create(:adapter, scripts: [script.id]) }
  let(:node)     { source.doc.at_xpath("//html") }

  before(:each) do
    refresh_index
    Extension.register_all
  end

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = ExtractDocumentFromNode::RunScriptSetters.call(
        instance: instance,
        node:     node,
        page:     page,
        adapter:  adapter
      )

      expect(result.instance['title']).to eq(title.downcase)
    end
  end
end
