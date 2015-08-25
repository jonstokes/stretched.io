class Page
  include Elasticsearch::Persistence::Model
  include Activisms

  has_many   :documents
  belongs_to :feed

  attr_accessor :visited, :doc, :body

  attribute :url,           String,   mapping: { index: 'not_analyzed' }
  attribute :code,          Integer,  mapping: { type:  'integer' }
  attribute :headers,       Hash,     mapping: { type:  'object' }
  attribute :error,         String,   mapping: { type:  'string', index: 'not_analyzed' }
  attribute :fetched_at,    Time,     mapping: { type:  'date' }

  # Stats
  attribute :visits,        Integer,  mapping: { type:  'integer' }
  attribute :response_time, Integer,  mapping: { type:  'integer' }
  attribute :scrape_time,   Integer,  mapping: { type:  'integer' }
  attribute :parse_times,   Hash,     mapping: { type:  'object' } # parse_times[adapter.name] = time

  validates :feed_id, presence: true
  validates :url,     presence: true, format: URI.regexp

  before_destroy { feed.page_queue.delete(url); true }

  def url=(val)
    self.id = self.class.url_to_id(val)
    super
  end

  def self.find_by_url(url)
    find(url_to_id(url))
  end

  def self.url_exists?(url)
    exists?(url_to_id(url))
  end

  def self.url_to_id(url)
    return unless url
    UUIDTools::UUID.parse_string(
      schemeless_url(url)
    ).to_s
  end

  def self.schemeless_url(url)
    return unless url
    url.split(/https?/).last
  end

  def update_from_source(source)
    @fetched_at = Time.current
    @visits ||= 0
    @visits += 1

    unless source.valid?
      @error = "Invalid"
      return
    end

    @code          = source.code
    @headers       = source.headers
    @error         = source.error
    @response_time = source.response_time
    @body          = source.body
    @doc           = source.doc
  end

  def to_hash
    super.except(:doc, :body)
  end
end
