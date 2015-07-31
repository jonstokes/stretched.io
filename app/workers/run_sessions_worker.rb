class RunSessionsWorker < Bellbro::Worker

  # Sidekiq
  include SidekiqUtils
  sidekiq_options queue: :stretched, retry: true

  # Delegations
  delegate :timed_out?, to: :timer

  # Logging
  track_with_schema(
    session_queue_size:  Integer,
    timed_out:           String,
    pages_scraped:       Integer,
    ssn_def:             String,
    ssn_user:            String,
    ssn_pages_scraped:   Integer,
    ssn_size:            Integer,
    ssn_mean_response:   Integer,  #ms
    ssn_median_response: Integer,  #ms
    ssn_mean_eff_response: Integer, #ms
    ssn_mean_parse:      Integer,  #ms
    ssn_median_parse:    Integer,  #ms
    ssn_mean_valid_parse: Integer,  #ms
    ssn_median_valid_parse: Integer, #ms
    ssn_duration:        Integer, #ms
    ssn_rate:            Integer,  #ms per page
    ssn_real_rate:       Integer,  #ms per page
    transition:          String,
    next_jid:            String
  )

  # Hooks
  before :should_run?, :set_domain, :track, :register_extensions

  after do
    timeout_insert = timed_out? ? ' [timeout]' : nil
    log "Worker for session queue #{session_q.name} finished#{timeout_insert}. #{session_q.size} sessions left in queue.;"
  end

  after :transition, :stop_tracking

  # Main
  def call
    record_update
    status_update(true)
    session_q.with do |q|
      while !timed_out? && (ssn = q.pop) do
        session = RunSession.call(stretched_session: ssn, timer: timer).stretched_session
        log_session_stats(session)
        q.push session if session.urls.any?
      end
    end
  end

  # Hook support
  def transition
    return unless should_run?
    next_jid = self.class.perform_async(user: user, queue: session_q.name)
    record_set(:transition, "RunSessionsWorker")
    record_set(:next_jid, next_jid)
  end

  def should_run?
    abort! unless debug? ||
        user &&
        session_q.try(:any?) &&
        jobs_in_flight_with_this_queue(user: @user, queue: session_q.name) < session_q.concurrency
  end

  def set_domain
    @domain = session_q.name
  end

  def register_extensions
    # Buzzsaw::Extension.register_all(user)
  end

  # Misc
  def log_session_stats(session)
    record_add(:pages_scraped, session.urls_popped)
    record_update(session.stats)
    status_update(true)
  end

  def record_update(attrs={})
    attrs.merge!(
      session_queue_size:  session_q.size,
      timed_out:           "#{timed_out?}"
    )
    super(attrs)
  end

  def jobs_in_flight_with_this_queue(opts)
    self.class.jobs_with_session_queue(opts).select { |j| jid != j[:jid] }.size +
      self.class.workers_with_session_queue(opts).select { |j| jid != j[:jid] }.size
  end

  def session_q
    @session_q ||= Session::Queue.find(context[:queue])
  end

  def timer
    @timer ||= RateLimiter.new(context[:timeout] || 1.hour.to_i)
  end
end