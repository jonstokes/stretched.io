FactoryGirl.define do
  factory :adapter do
    transient do
      domain { create(:domain) }
      schema { create(:schema) }
      scripts { [create(:script)] }
    end
    name              { "#{domain.id}/product" }
    mapping           { create(:mapping).id }
    schema_name       { schema.name }
    xpath             "//html"
    script_names        { scripts.map(&:name) }
    property_setters  {
      { title: [{find_by_xpath: {xpath: "//title"}}] }
    }
  end
end
