FactoryGirl.define do
  factory :document, class: Document do
    transient do
      source  { create(:sunbro_page) }
      page    { create(:page, source: source) }
      adapter { create(:adapter) }
    end
    id          { SecureRandom.uuid }
    page_id     { page.id }
    adapter_id  { adapter.id }
    properties  {{ title: source.doc.at_xpath("//title").text }}
  end
end
