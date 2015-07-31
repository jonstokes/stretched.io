module Session
  class Queue < ActiveRecord::Base
    self.table_name = 'session_queues'

    belongs_to :rate_limit
    has_many   :sessions, class_name: "Session:Session"

    validates :name,          presence: true
    validates :max_size,      presence: true, numericality: { greater_than: 0 }
    validates :rate_limit_id, presence: true

    def pop
      # atomic pop from queue
    end

    def with_limit
      rate_limiter.with_limit(limiter_key) do
        yield
      end
    end

    private

    def limiter_key
      "#{self.class.name}::#{name}"
    end
  end
end
