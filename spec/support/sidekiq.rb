require 'sidekiq/api'

def clear_sidekiq
  Sidekiq::Worker.clear_all
  Sidekiq::Queue.new('stretched').clear
end
