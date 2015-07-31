FactoryGirl.define do
  factory :sunbro_page, class: Sunbro::Page do
    skip_create

    transient { domain { "www.retailer.com" } }
    sequence(:url)  { |n| "http://#{domain}/#{n}" }
    sequence(:body) { |n|
      <<-EOS
        <html>
          <header>
            <title>Page #{n}</title>
          </header>
          <body>
          </body>
        </html>
      EOS
    }
    code 200
    response_time 100
    headers {
      {
        "server": ["nginx"],
        "date": [Time.current.utc.to_s],
        "content-type": ["text/html; charset=UTF-8"],
        "transfer-encoding": ["chunked"],
        "connection": ["keep-alive"],
      }
    }

    initialize_with do
      new(
        attributes[:url],
        attributes.except(:url)
      )
    end
  end
end