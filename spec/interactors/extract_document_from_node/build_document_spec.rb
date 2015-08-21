require 'spec_helper'

describe ExtractDocumentFromNode::BuildDocument do
  let(:instance) {
    {
      'title' => 'Page 1',
      'price' => 'invalid',
      'status' => 100,
      'unknown_attribute' => 100
    }
  }

  let(:schema)  {
    create(
      :schema,
      data: {
        "type" => "object",
        "$schema" => "http://json-schema.org/draft-04/schema",
        "properties" => {
          "id"     => { "type" => "string" },
          "title"  => { "type" => "string" },
          "price"  => { "type" => "integer" },
          "status" => { "type" => "string" }
        },
        "required" => ["title"]
      }
    )
  }

  let(:adapter) { create(:adapter, schema: schema) }
  let(:page)    { create(:page) }

  describe "#call" do
    it "builds a document with a random ID in UUID format" do
      result = ExtractDocumentFromNode::BuildDocument.call(
        instance: instance,
        adapter: adapter,
        page: page
      )
      expect(result.document).to be_a(Document)
      expect(UUIDTools::UUID.validate(result.document.id)).to eq(true)
    end

    it "builds a document with an ID in UUID format based on the adapter's id_property field" do
      adapter.update(id_property: 'id')
      instance.merge!('id' => '://www.retailer.com/1')

      result = ExtractDocumentFromNode::BuildDocument.call(
        instance: instance,
        adapter: adapter,
        page: page
      )
      expect(result.document).to be_a(Document)
      expect(UUIDTools::UUID.validate(result.document.id)).to eq(true)
      expect(result.document.id).to eq(UUIDTools::UUID.parse_string(instance['id']).to_s)
    end
  end
end
