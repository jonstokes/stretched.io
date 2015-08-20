FactoryGirl.define do
  factory :schema do
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
