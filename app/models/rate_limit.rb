class RateLimit < ActiveRecord::Base
  has_many :session_queues,  class_name: "Session::Queue"
  has_many :document_queues, class_name: "Document::Queue"

  validates :peak_start,    presence: true
  validates :peak_duration, presence: true
  validates :peak_rate,     presence: true
  validates :off_peak_rate, presence: true
end
