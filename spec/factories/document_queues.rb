FactoryGirl.define do
  factory :document_queue, class: Document::Queue do
    rate_limit
    name     "www.retailer.com/product"
    max_size 100
  end
end
