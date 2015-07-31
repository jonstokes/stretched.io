require 'sidekiq/api'

module SidekiqUtils
  def jobs_in_flight_with_session_queue(opts)
    jobs_with_session_queue(opts) + workers_with_session_queue(opts)
  end

  def active_workers
    _workers.map do |w|
      {
        session_queue: worker_session_queue(w),
        jid:           worker_jid(w),
        time:          worker_time(w)
      }
    end
  end

  def queued_jobs
    _jobs.map do |j|
      {
        session_queue: job_session_queue(j),
        jid:           job_jid(j)
      }
    end
  end

  def workers_with_session_queue(opts)
    active_workers.select do |w|
      w[:session_queue] == opts[:queue]
    end
  end

  def worker_session_queue(worker)
    worker["payload"]["args"].first["queue"] if worker["payload"] && worker["payload"]["args"].try(:any?)
  end

  def jobs_with_session_queue(opts)
    queued_jobs.select do |j|
      j[:session_queue] == opts[:queue]
    end
  end

  def job_session_queue(job)
    job.args.first["queue"] if job.args.any?
  end
end
