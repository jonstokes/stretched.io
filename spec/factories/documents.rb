FactoryGirl.define do
  factory :document, class: Document::Document do
    association :session_reader, factory: :session_reader

    page        { create(:page) }
    properties  {{ title: page.doc.at_xpath("//title").text }}
  end
end
