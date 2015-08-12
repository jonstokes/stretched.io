require 'spec_helper'

describe ExtractDocumentFromNode::RunJsonSetters do
  let(:title)    { "PAGE 1" }
  let(:instance) { ActiveSupport::HashWithIndifferentAccess.new('price' => 100) }
  let(:source)   { create(:sunbro_page, title: title) }
  let(:page)     { create(:page, source: source) }
  let(:adapter)  { create(:adapter) }
  let(:node)     { source.doc.at_xpath("//html") }

  describe "#call" do
    it "correctly mutates the instance hash based on the adapter and the page" do
      result = ExtractDocumentFromNode::RunJsonSetters.call(
        node:     node,
        page:     page,
        instance: instance,
        adapter:  adapter
      )
      expect(instance['title']).to eq(title)
      expect(instance['price']).to eq(100) # decoy
    end
  end
end
