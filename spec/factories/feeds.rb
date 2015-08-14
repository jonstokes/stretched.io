FactoryGirl.define do
  factory :feed, class: Feed do
    transient do
      domain    { create(:domain) }
      adapter   { create(:adapter, domain: domain) }
      url_count { 5 }
    end

    domain_id     { domain.id }
    adapter_ids   { [adapter.id] }
    page_format   :html
    urls          {
      url_count.times.map { |n| { url: "http://#{domain.id}/#{n}" } }
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
