FactoryGirl.define do
  factory :adapter do
    transient do
      domain { create(:domain) }
      schema { create(:schema) }
    end
    schema_id         { schema.id }
    id                { "#{domain.id}/product" }
    xpath             "//html"
    attribute_setters {{ title: [{find_by_xpath: {xpath: "//title"}}] }}
  end
end
