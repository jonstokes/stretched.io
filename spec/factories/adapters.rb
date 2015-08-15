FactoryGirl.define do
  factory :adapter do
    transient do
      domain { create(:domain) }
      schema { create(:schema) }
      scripts { [create(:script)] }
    end
    schema_id         { schema.id }
    id                { "#{domain.id}/product" }
    xpath             "//html"
    script_ids        { scripts.map(&:id) }
    property_setters  {
      { title: [{find_by_xpath: {xpath: "//title"}}] }
    }
  end
end
