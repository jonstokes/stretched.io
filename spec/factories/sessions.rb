FactoryGirl.define do
  factory :session, class: Session::Session do
    association :session_queue, factory: :session_queue
    transient do
      domain    { "www.retailer.com" }
      url_count { 5 }
    end
    page_format       :html
    document_adapters { ["#{domain}/product"] }
    urls              { url_count.times.map { |n| "http://#{domain}/#{n}" } }
  end
end
