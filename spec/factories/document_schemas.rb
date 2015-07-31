FactoryGirl.define do
  factory :document_schema, class: Document::Schema do
    name "www.retailer.com/product"
    data {
      { "key" => "value" }
    }
  end
end
