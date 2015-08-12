FactoryGirl.define do
  factory :page, class: Page do
    transient do
      sequence(:title) { |n| "Page #{n}" }
      feed             { create(:feed) }
      source           { create(:sunbro_page, title: title) }
    end

    feed_id            { feed.id }
    url                { source.url.to_s }
    code               { source.code }
    response_time      { source.response_time }
    headers            { source.headers }
    body               { source.body }
    doc                { source.doc }
    fetched_at         { Time.current }
  end
end
