class RateLimit < ActiveRecord::Base
  has_many :session_queues,  class_name: "Session::Queue"
  has_many :document_queues, class_name: "Document::Queue"

  validates :peak_start,    presence: true
  validates :peak_duration, presence: true
  validates :peak_rate,     presence: true
  validates :off_peak_rate, presence: true

  def with_limit(subject, &block)
    # FIXME: Add redis support
    limiter.exec_within_threshold(subject, threshold: 1, interval: rate) do
      limiter.add(subject)
      yield
    end
  end

  def limiter
    @limiter ||= Ratelimit.new(self.class.name)
  end

  def rate
    # Rates are in seconds per action, so a rate of 2 would
    # mean 1 action every 2 seconds.
    peak? ? peak_rate : off_peak_rate
  end

  def peak?
    (Time.current >= peak_start) && (Time.current <= peak_start + peak_duration)
  end
end
