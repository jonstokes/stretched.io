FactoryGirl.define do
  factory :session, class: Session::Session do
    association :session_queue, factory: :session_queue
    page_format       :html
    document_adapters %w(www.retailer.com/product)
    urls              [ { url: 'http://www.retailer.com/1' }]
  end
end
