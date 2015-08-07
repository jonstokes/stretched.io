class RunSession
  include Troupe
  include Chronograph
  include Sunbro

  before { ssn.start! }

  after { ssn.stop! }

  expects :ssn, :timer

  def call
    while !timed_out? && url = ssn.pop_url
      page = measure(:scrape_time) do
        Retryable.retryable(sleep: retry_sleep, tries: 2) { scrape_page(url) } || Sunbro::Page.new(url)
      end

      documents = measure(:parse_time) do
        ExtractDocumentsFromPage.call(
          page: page,
          ssn: ssn,
          browser_session: browser_session
        ).documents
      end

      AddDocumentsToQueues.call(documents: documents)

      # ssn.stats.parse_times << results.stats.parse_time
    end
  ensure
    close_http_connections
  end

  def timed_out?
    timer ? timer.timed_out? : false
  end

  def retry_sleep
    Rails.env.test? ? 0.1 : 1
  end

  def browser_session
    return unless @dhttp
    @dhttp.session
  end

  def scrape_page(url)
    case ssn.page_format.downcase
    when "dhtml"
      ssn.with_limit { render_page(url) }
    when "xml"
      ssn.with_limit { get_page(url, force_format: :xml) }
    when "html"
      ssn.with_limit { get_page(url, force_format: :html) }
    else
      ssn.with_limit { get_page(url) }
    end
  end
end
