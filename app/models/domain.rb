class Domain
  include Elasticsearch::Persistence::Model
  include Activisms
  include Redis::Objects

  set :readers

  belongs_to :rate_limit
  has_many   :feeds

  attribute :max_readers, Integer, mapping: { type:  'integer' }, default: 1

  validates :id,            presence: true
  validates :max_readers,   presence: true
  validates :rate_limit_id, presence: true

  def read(jid)
    return false if full?
    readers << jid
    jid
  end

  def full?
    readers.size >= concurrency
  end

  def with_limit
    rate_limit.with_limit(limiter_key) do
      yield
    end
  end

  private

  def limiter_key
    @limiter_key ||= "#{self.class.name}::#{id}"
  end
end
