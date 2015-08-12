class Feed
  include Elasticsearch::Persistence::Model
  include Activisms
  include Redis::Objects

  sorted_set :page_queue, :global => true

  belongs_to      :domain
  has_many        :pages
  belongs_to_many :adapters

  attribute  :page_format,   String,  mapping: { index: 'not_analyzed' }
  attribute  :adapter_id,    String,  mapping: { index: 'not_analyzed' }
  attribute  :urls,          Array,   mapping: {
                                        type: 'object',
                                        properties: {
                                          url:           { type: 'string', index: 'not_analyzed' },
                                          start_at_page: { type: 'integer' },
                                          stop_at_page:  { type: 'integer' },
                                          step:          { type: 'integer' }
                                        }
                                      }
  attribute  :read_interval, Integer, mapping: { type:  'integer' }
  attribute  :sessions,      Array,   mapping: { type:  'object' }, default: []

  validates :domain_id,     presence: true, length: {minimum: 3}
  validates :adapter_ids,   presence: true
  validates :page_format,   presence: true, inclusion: { in: ['html', :html, 'xml', :xml, 'dhtml', :dhtml] }
  validates :urls,          presence: true
  validates :read_interval, presence: true, numericality: { greater_than_or_equal_to: 60, only_integer: true }

  after_destroy do
    clear_redis
    unlink_pages
  end

  delegate :with_limit, to: :domain

  def pop_page
    return unless url = page_queue.pop
    Page.find_by_url(url)
  end

  def expanded_urls
    @expanded_urls ||= urls.present? ? expand_urls : []
  end

  def has_url?(url)
    expanded_urls.include?(url)
  end

  def start(opts={})
    link_pages
    queue_stale_pages
    session.start_size = page_queue.size
    session.started_at = Time.current
    opts.each do |k, v|
      session.send("#{k}=", v)
    end
  end

  def stop(opts={})
    raise "Feed not started!" unless session.start_size
    session.pages_scraped = session.start_size - page_queue.size
    session.duration = (Time.current - session.started_at).to_f / 60.0
    opts.each do |k, v|
      session.send("#{k}=", v)
    end
    sessions << session
    save
  end

  def session
    @session ||= Session.new
  end

  def to_hash
    super.except(:session, :expanded_urls, :page_queue)
  end

  def clear_redis
    page_queue.clear
  end

  def has_stale_pages?
    Page.count(stale_pages_query) > 0
  end

  def self.clear_redis
    self.all.to_a.each(&:clear_redis)
  end

  private

  def queue_stale_pages
    Page.find_each(stale_pages_query) do |page|
      page_queue[page.url] = page.fetched_at.try(:to_i) || 1
    end
  end

  def stale_pages_query
    {
      query: {
        filtered: {
          filter: {
            bool: {
              must: {
                term:  { feed_id: id }
              },
              should: [
                { missing: { field: 'fetched_at' } },
                { range: { fetched_at: { lte: read_interval.seconds.ago } } }
              ]
            }
          }
        }
      },
      sort: { fetched_at: { order: 'asc'} }
    }
  end

  def link_pages
    # FIXME: only accept urls that are part of this feed's domain.
    # Batch write
    expanded_urls.each do |url|
      next if Page.find_by_url(url)
      Page.create(feed_id: id, url: url)
    end
  end

  def unlink_pages
    # FIXME: Batch delete
    each_page do |page|
      page.destroy
    end
  end

  def expand_urls
    urls.map do |link|
      expand_links(link)
    end.flatten.uniq
  end

  def expand_links(link)
    link.symbolize_keys!
    return link[:url] unless link[:start_at_page]
    (link[:start_at_page]..link[:stop_at_page]).step(link[:step] || 1).map do |page_number|
      link[:url].sub("PAGENUM", page_number.to_s)
    end
  end
end
