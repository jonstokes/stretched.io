FactoryGirl.define do
  factory :document_adapter, class: Document::Adapter do
    association :document_schema, factory: :document_schema
    association :document_queue,  factory: :document_queue
    name        "www.retailer.com/product"
    xpath       "//html"
    property_queries {
      {
        title: [{find_by_xpath: {xpath: "//div"}}]
      }
    }
  end

end