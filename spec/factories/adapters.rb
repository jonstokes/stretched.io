FactoryGirl.define do
  factory :adapter do
    transient do
      domain { "www.retailer.com" }
      schema { create(:schema) }
    end
    schema_id         { schema.id }

    id                { "#{domain}/product" }
    xpath             "//html"
    attribute_setters {{ title: [{find_by_xpath: {xpath: "//title"}}] }}
  end
end
