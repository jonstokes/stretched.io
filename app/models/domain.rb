class Domain
  include Elasticsearch::Persistence::Model
  include Activisms
  include Redis::Objects
  include NameAsUUID

  set        :readers

  belongs_to :rate_limit,     by: :name
  has_many   :feeds,          dependent: :destroy

  attribute :max_readers,     Integer, mapping: { type:  'integer' }, default: 1
  validates :max_readers,     presence: true
  validates :rate_limit_name, presence: true

  before_destroy do
    clear_redis
  end

  def read_with(jid)
    readers << jid
  end

  def full?
    readers.size >= max_readers
  end

  def available?
    !full?
  end

  def with_limit
    rate_limit.with_limit(limiter_key) do
      yield
    end
  end

  def clear_redis
    readers.clear
  end

  def self.clear_redis
    self.all.to_a.each(&:clear_redis)
  end

  private

  def limiter_key
    @limiter_key ||= "#{self.class.name}::#{id}"
  end
end
