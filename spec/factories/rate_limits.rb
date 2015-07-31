FactoryGirl.define do
  factory :rate_limit do
    peak_start { Time.now }
    peak_duration 10
    peak_rate 1.0
    off_peak_rate 2.0
  end
end
