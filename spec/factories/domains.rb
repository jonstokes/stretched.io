FactoryGirl.define do
  factory :domain, class: Domain do
    transient       { rate_limit { create(:rate_limit) } }
    name            { "www.retailer.com" }
    rate_limit_name { rate_limit.name }
    max_readers     { 2 }
  end
end
