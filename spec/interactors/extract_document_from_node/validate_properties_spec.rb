require 'spec_helper'

describe ExtractDocumentFromNode::ValidateProperties do
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
          "title" =>  { "type" => "string" },
          "price" =>  { "type" => "integer" },
          "status" => { "type" => "string" }
        },
        "required" => ["title"]
      }
    )
  }

  let(:adapter) { create(:adapter, schema: schema) }

  describe "#call" do
    it "deletes invalid key/value pairs from the instance hash" do
      result = ExtractDocumentFromNode::ValidateProperties.call(instance: instance, adapter: adapter)
      expect(result.instance).to eq(
        {'title' => 'Page 1', 'unknown_attribute' => 100}
      )
    end
  end
end
