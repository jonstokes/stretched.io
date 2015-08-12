class RunFeedWorker < Bellbro::Worker
  sidekiq_options queue: :stretched, retry: true

  attr_reader :domain, :feed

  before :should_run?
  before do
    @domain = Domain.find(context[:domain])
    @feed   = Feed.find(context[:feed])
    Buzzsaw::Extension.register_all
  end

  after do
    state = timed_out? ? 'timed out' : 'finished'
    log "Worker for feed #{feed.id} #{state}. #{feed.page_queue.size} pages left in queue."
    transition
  end

  time_out_in 1.hour

  def call
    feed.start(jid: jid)
    RunSession.call(feed: feed, timer: timer)
  ensure
    feed.stop(timed_out: timed_out?)
  end

  private

  def transition
    return unless should_run?
    self.class.perform_async(queue: session_q.name)
  end

  def should_run?
    return true if debug? || (feed.has_stale_pages? && !domain.full?)
    abort!
  end
end
