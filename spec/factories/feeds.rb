FactoryGirl.define do
  factory :feed, class: Feed do
    transient do
      domain    { create(:domain, id: "www.retailer.com") }
      adapter   { create(:adapter) }
      url_count { 5 }
    end

    domain_id     { domain.id }
    adapter_ids   { [adapter.id] }
    page_format   :html
    urls          {
      url_count.times.map { |n| { url: "http://#{domain.id}/#{n}" } }
    }
    read_interval { 3600 }
  end
end
