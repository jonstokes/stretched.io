FactoryGirl.define do
  factory :sunbro_page, class: Sunbro::Page do
    skip_create

    transient do
      sequence(:title) { |n| "Page #{n}" }
    end

    sequence(:url)  { |n| "http://www.retailer.com/#{n}" }
    body            { |n|
      <<-EOS
        <html>
          <header>
            <title>#{title}</title>
          </header>
          <body>
          </body>
        </html>
      EOS
    }
    code          200
    response_time 100
    headers       {
      {
        "server" => ["nginx"],
        "date"   => [Time.current.utc.to_s],
        "content-type" => ["text/html; charset=UTF-8"],
        "transfer-encoding" => ["chunked"],
        "connection" => ["keep-alive"],
      }
    }
    doc { Nokogiri.parse(body) }

    initialize_with do
      new(
        attributes[:url],
        attributes.except(:url)
      )
    end
  end
end
