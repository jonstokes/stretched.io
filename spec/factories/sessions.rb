FactoryGirl.define do
  factory :session, class: Session::Session do
    transient do
      domain    { "www.retailer.com" }
      url_count { 5 }
    end

    association   :session_queue, factory: :session_queue
    adapter_names { [create(:document_adapter).name] }
    page_format   :html
    urls          {
      url_count.times.map { |n| { url: "http://#{domain}/#{n}" } }
    }
  end
end
