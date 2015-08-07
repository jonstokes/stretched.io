module Session
  class Queue < ActiveRecord::Base
    include Redis::Objects
    include CommonFinders

    self.table_name = 'session_queues'

    belongs_to :rate_limit
    has_many   :sessions,        class_name: "Session::Session"
    has_many   :session_readers, class_name: "Session::Reader"

    validates :name,          presence: true
    validates :max_size,      presence: true, numericality: { greater_than: 0 }
    validates :concurrency,   presence: true, numericality: { greater_than: 0 }
    validates :rate_limit_id, presence: true

    counter :readers

    def push(arg)
      if arg.is_a?(Enumerable)
        arg.each { |s| _push(s) }
      else
        _push(arg)
      end
    end
    alias_method :add, :push

    def pop
      db do |conn|
        next unless record = sessions.lock(true).first
        record.update!(session_queue: nil)
        record
      end
    end

    def size
      db { sessions.count }
    end
    alias_method :count, :size

    def sessions
      db { Session.where(session_queue_id: id) }
    end

    def is_being_read?
      any? || (readers > 0)
    end

    def any?
      !empty?
    end

    def empty?
      self.size.zero?
    end

    def with
      read!
      yield self
    ensure
      stop_reading!
    end

    def read!
      readers.increment
    end

    def stop_reading!
      if readers > 0
        readers.decrement
      elsif readers < 0
        readers.reset
      end
    end

    def with_limit
      rate_limit.with_limit(limiter_key) do
        yield
      end
    end

    private

    def _push(session)
      db { session.update(session_queue: self) }
      session
    end

    def limiter_key
      "#{self.class.name}::#{name}"
    end
  end
end
