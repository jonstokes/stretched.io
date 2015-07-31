module Session
  class Session < ActiveRecord::Base
    belongs_to :session_queue
    has_may :pages
  end
end
