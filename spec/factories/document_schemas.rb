FactoryGirl.define do
  factory :document_schema, class: Document::Schema do
    name "www.retailer.com/product"
    data {
      {
        "type" => "object",
        "$schema" => "http://json-schema.org/draft-04/schema",
        "properties" => {
          "title" => { "type" => "string" },
          "price" => { "type" => "integer" }
        },
        "required" => ["title"]
      }
    }
  end
end
