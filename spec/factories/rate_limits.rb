FactoryGirl.define do
  factory :rate_limit do
    sequence(:name) { |n| "test/rate_limit_#{n}" }
    peak_start      { Time.now }
    peak_duration   10
    peak_rate       0.01
    off_peak_rate   0.02
  end
end
