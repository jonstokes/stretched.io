class RunSession
  include Troupe
  include Chronograph
  include Sunbro

  expects :feed, :timer

  provides(:conn) { Sunbro::Connection.new }

  benchmark_with :benchmarks

  def call
    while !timed_out? && page = feed.pop_page
      source = benchmark(:scrape_time) do
        conn.fetch_page(
          page.url,
          force_format: feed.page_format.to_s.downcase,
          tries:        2,
          sleep:        retry_sleep
        ) || Sunbro::Page.new(page.url)
      end

      page.update_from_source(source)
      page.scrape_time = context.benchmarks[:scrape_time]

      if source.valid?
        result = ExtractDocumentsFromPage.call(
          page: page,
          feed: feed,
          browser_session: browser_session
        )

        page.parse_times = result.parse_times

        SaveDocuments.call(documents: result.documents)
      end

      feed.session.run_stats(page)
      page.save
    end
  ensure
    conn.close
  end

  def timed_out?
    timer ? timer.timed_out? : false
  end

  def retry_sleep
    Rails.env.test? ? 0.1 : 1
  end

  def browser_session
    conn.session
  end
end
