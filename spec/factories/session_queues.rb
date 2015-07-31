FactoryGirl.define do
  factory :session_queue, class: Session::Queue do
    rate_limit
    name     "www.retailer.com"
    max_size 100
  end
end
