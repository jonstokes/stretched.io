module Session
  class Session < ActiveRecord::Base
    belongs_to :session_queue, class_name: "Session::Queue"
    has_many   :pages,         dependent: :destroy

    validates :session_queue_id,  presence: true
    validates :page_format,       presence: true, inclusion: { in: %w(html xml dhtml) }
    validates :document_adapters, presence: true
    validates :urls,              presence: true
  end
end
