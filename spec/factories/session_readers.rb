FactoryGirl.define do
  factory :session_reader, class: Session::Reader do
    association :session_queue,    factory: :session_queue
    association :document_adapter, factory: :document_adapter
    association :session,          factory: :session
  end
end
