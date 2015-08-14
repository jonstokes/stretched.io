class RunFeedWorker < Bellbro::Worker
  sidekiq_options queue: :stretched, retry: true

  before :should_run?
  before { Extension.register_all }

  after do
    state = timed_out? ? 'timed out' : 'finished'
    Rails.logger.info "Worker for feed #{feed.id} #{state}. #{feed.page_queue.size} pages left in queue."
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

  def feed
    @feed ||= Feed.find(context[:feed_id])
  end

  def domain
    feed.domain
  end

  def transition
    return unless should_run?
    self.class.perform_async(feed_id: feed.id)
  end

  def should_run?
    return true if debug? || (feed.has_stale_pages? && !domain.full?)
    abort!
  end
end
