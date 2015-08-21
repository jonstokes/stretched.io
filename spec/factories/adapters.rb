FactoryGirl.define do
  factory :adapter do
    transient do
      domain { create(:domain) }
      schema { create(:schema) }
      scripts { [create(:script)] }
    end
    schema_name       { schema.name }
    name              { "#{domain.id}/product" }
    xpath             "//html"
    script_names        { scripts.map(&:name) }
    property_setters  {
      { title: [{find_by_xpath: {xpath: "//title"}}] }
    }
  end
end
