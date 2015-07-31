FactoryGirl.define do
  factory :document, class: Document::Document do
    association :document_queue,   factory: :document_queue
    association :document_adapter, factory: :document_adapter
    association :page,             factory: :page
    properties {
      {
        title: "Page Title"
      }
    }
  end

end
