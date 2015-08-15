FactoryGirl.define do
  factory :feed, class: Feed do
    transient do
      domain    { create(:domain) }
      adapters  { [create(:adapter, domain: domain)] }
    end

    domain_id     { domain.id }
    adapter_ids   { adapters.map(&:id) }
    page_format   :html
    urls          {
      5.times.map { |n| { url: "http://#{domain.id}/#{n}" } }
    }
    read_interval { 3600 }

    trait(:with_pages) do
      after(:create) do |feed|
        feed.send(:link_pages)
        refresh_index
      end
    end
  end
end
