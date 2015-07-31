FactoryGirl.define do
  factory :session_queue, class: Session::Queue do
    transient { domain { "www.retailer.com" } }
    rate_limit
    name     { domain }
    max_size 100
    concurrency 5
  end
end
