module Session
  class Queue < ActiveRecord::Base
    self.table_name = 'session_queues'

    belongs_to :rate_limit
    has_many   :sessions, class_name: "Session::Session"

    validates :name,          presence: true
    validates :max_size,      presence: true, numericality: { greater_than: 0 }
    validates :rate_limit_id, presence: true

    def push(arg)
      if arg.is_a?(Enumerable)
        arg.each { |s| _push(s) }
      else
        _push(arg)
      end
    end
    alias_method :add, :push

    def pop
      with_limit { _pop }
    end

    def size
      sessions.count
    end

    def sessions
      db { Session.where(session_queue_id: id) }
    end

    def with_limit
      rate_limit.with_limit(limiter_key) do
        yield
      end
    end

    private

    def _push(session)
      session.session_queue = self
      db { session.save! }
      session
    end

    def _pop
      db do |conn|
        next unless record = sessions.lock(true).first
        record.destroy
        record
      end
    end

    def db(&b); ActiveRecord::Base.connection_pool.with_connection(&b); end

    def limiter_key
      "#{self.class.name}::#{name}"
    end
  end
end
