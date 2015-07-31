FactoryGirl.define do
  factory :document_queue, class: Document::Queue do
    transient { domain { "www.retailer.com" } }
    rate_limit
    name     { "#{domain}/product" }
    max_size 100
  end
end
