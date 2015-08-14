class RunFeedsService < Bellbro::Service

  poll_interval     Rails.env.test? ? 1 : 15
  track_with_schema jobs_started: Integer
  worker_class      RunFeedWorker

  def start_jobs
    Feed.each_stale do |feed|
      next unless should_add_job?(feed)
      jid = worker_class.perform_async(feed_id: feed.id)
      feed.domain.read_with(jid)
      Rails.logger.info "Starting job #{jid} RunFeedWorker for domain #{feed.domain.id} and feed #{feed.id}."
    end
  end

  def should_add_job?(feed)
    feed.domain.available? && worker_class.jobs_in_flight_with(feed_id: feed.id).empty?
  end
end
