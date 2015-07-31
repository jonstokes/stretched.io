FactoryGirl.define do
  factory :page do
    association :session, factory: :session
    sequence(:url) { |n| "http://www.retailer.com/#{n}" }
    code 200
    response_time 100 #ms
    headers {
      {
        "server": ["nginx"],
        "date": [Time.current.utc.to_s],
        "content-type": ["text/html; charset=UTF-8"],
        "transfer-encoding": ["chunked"],
        "connection": ["keep-alive"],
      }
    }
  end
end
