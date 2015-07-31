FactoryGirl.define do
  factory :page do
    association :session, factory: :session

    transient do
      domain { "www.retailer.com" }
      source { create(:sunbro_page, domain: domain) }
    end

    url           { source.url.to_s }
    code          { source.code }
    response_time { source.response_time }
    headers       { source.headers }
  end
end
