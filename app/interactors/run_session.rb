require 'benchmark'

class RunSession
  include Interactor
  include Sunbro
  include Bellbro::Ringable

  # Hooks
  before do
    stretched_session.start!
    @retry_sleep = Rails.env.test? ? 0.1 : 1
    @objects = Hash[stretched_session.object_adapters.map { |a| [a.key, []] }]
  end

  after do
    stretched_session.stop!
  end

  # Contract
  expects :stretched_session, :browser_session, :timer

  # Main
  def call
    while !timed_out? && url = stretched_session.pop_url
      next unless page = Retryable.retryable(sleep: @retry_sleep, tries: 2) { scrape_page(url) }

      stretched_session.response_times << page.response_time
      parse_time = 0
      stretched_session.object_adapters.each do |adapter|
        start = Time.now
        parse_page(page, adapter)
        finish = Time.now
        parse_time += ((finish - start) * 1000)
      end
      stretched_session.parse_times << parse_time
    end
  ensure
    close_http_connections
    add_objects_to_adapter_queues
  end

  def add_objects_to_adapter_queues
    stretched_session.object_adapters.each do |a|
      a.object_queue.push @objects[a.key]
    end
  end

  def timed_out?
    return false unless context.timer
    context.timer.timed_out?
  end

  def parse_page(page, adapter)
    if page.is_valid?
      results = ExtractJsonFromPage.call(
        user:            stretched_session.user,
        page:            page,
        adapter:         adapter,
        browser_session: browser_session
      )
      @objects[adapter.key] << format_objects_for_queue(adapter, page, results.json_objects)
    else
      @objects[adapter.key] << format_objects_for_queue(adapter, page, [])
    end
    error "Page Error: #{page.error.message} at url #{page.url}" if page.error
  rescue Exception => e
    unless e.is_a?(Sidekiq::Shutdown)
      adapter.object_queue.add format_error_for_queue(adapter, page, e)
      error "#{e.message} raised by session #{stretched_session.inspect}."
      Airbrake.notify(e)
    end
  end

  private

  def format_error(e)
    error = "#{e.message} #{e.inspect}\n"
    return error unless e.backtrace && e.backtrace[1..10]
    e.backtrace[1..10].each do |line|
      error << "#{line}\n"
    end
    error
  end

  def format_objects_for_queue(adapter, page, json_objects)
    json_objects = [{}] if json_objects.empty?
    json_objects.map do |obj|
      {
        object: obj,
        page: page_to_hash(page),
        session: {
          key:                stretched_session.key,
          started_at:         stretched_session.started_at,
          queue:              stretched_session.queue_name,
          session_definition: stretched_session.definition_key,
          object_adapter:     adapter.key
        }
      }
    end
  end

  def format_error_for_queue(adapter, page, error)
    {
      error: format_error(error),
      page: page_to_hash(page),
      session: {
        key:                stretched_session.key,
        started_at:         stretched_session.started_at,
        queue:              stretched_session.queue_name,
        session_definition: stretched_session.definition_key,
        object_adapter:     adapter.key
      }
    }
  end

  def browser_session
    return unless @dhttp
    @dhttp.session
  end

  def scrape_page(url)
    case stretched_session.page_format.downcase
    when "dhtml"
      stretched_session.with_limit { render_page(url) }
    when "xml"
      stretched_session.with_limit { get_page(url, force_format: :xml) }
    when "html"
      stretched_session.with_limit { get_page(url, force_format: :html) }
    else
      stretched_session.with_limit { get_page(url) }
    end
  end

  def page_to_hash(page)
    hash = page.to_hash
    hash.merge('body' => !!hash['body'])
  end

  def stretched_session
    context.stretched_session
  end

end
