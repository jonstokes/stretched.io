module Session
  class Queue < ActiveRecord::Base
    self.table_name = 'session_queue'

    belongs_to :rate_limits
    has_many :sessions
  end
end
