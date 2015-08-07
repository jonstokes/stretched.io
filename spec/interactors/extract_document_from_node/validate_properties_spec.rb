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
      :document_schema,
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

  let(:adapter) { create(:document_adapter, document_schema: schema) }
  let(:reader)   { create(:session_reader, document_adapter: adapter)}

  describe "#call" do
    it "deletes invalid key/value pairs from the instance hash" do
      result = ExtractDocumentFromNode::ValidateProperties.call(instance: instance, reader: reader)
      expect(result.instance).to eq(
        {'title' => 'Page 1', 'unknown_attribute' => 100}
      )
    end
  end
end
