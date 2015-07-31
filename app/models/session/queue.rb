module Session
  class Queue < ActiveRecord::Base
    self.table_name = 'session_queues'

    belongs_to :rate_limit
    has_many   :sessions, class_name: "Session:Session"

    validates :name,          presence: true
    validates :max_size,      presence: true, numericality: { greater_than: 0 }
    validates :rate_limit_id, presence: true
  end
end
