class RateLimit < ActiveRecord::Base
  has_many :session_queues
  has_many :document_queues
end
