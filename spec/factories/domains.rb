FactoryGirl.define do
  factory :domain, class: Domain do
    transient     { rate_limit { create(:rate_limit) } }
    id            { "www.retailer.com" }
    rate_limit_id { rate_limit.id }
    max_readers   { 2 }
  end
end
