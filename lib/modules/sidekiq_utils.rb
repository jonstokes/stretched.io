module SidekiqUtils
  def jobs_in_flight_with_session_queue(opts)
    jobs_with_session_queue(opts) + workers_with_session_queue(opts)
  end

  def active_workers
    _workers.map do |w|
      {
          session_queue: worker_session_queue(w),
          user:          worker_user(w),
          jid:           worker_jid(w),
          time:          worker_time(w)
      }
    end
  end

  def queued_jobs
    _jobs.map do |j|
      {
          session_queue: job_session_queue(j),
          user:          job_user(j),
          jid:           job_jid(j)
      }
    end
  end

  def workers_with_session_queue(opts)
    active_workers.select do |w|
      (w[:session_queue] == opts[:queue]) &&
          (w[:user] == opts[:user])
    end
  end

  def worker_user(worker)
    worker["payload"]["args"].first["user"] if worker["payload"] && worker["payload"]["args"].try(:any?)
  end

  def worker_session_queue(worker)
    worker["payload"]["args"].first["queue"] if worker["payload"] && worker["payload"]["args"].try(:any?)
  end


  def jobs_with_session_queue(opts)
    queued_jobs.select do |j|
      (j[:session_queue] == opts[:queue]) &&
          (j[:user] == opts[:user])
    end
  end

  def job_user(job)
    job.args.first["user"] if job.args.any?
  end

  def job_session_queue(job)
    job.args.first["queue"] if job.args.any?
  end
end