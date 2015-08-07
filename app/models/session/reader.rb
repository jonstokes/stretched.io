module Session
  class Reader < ActiveRecord::Base
    self.table_name = 'session_readers'

    belongs_to :document_adapter, class_name: "Document::Adapter"
    belongs_to :session,          class_name: "Session::Session"
    belongs_to :session_queue,    class_name: "Session::Queue"

    validates :document_adapter_id, presence: true
    validates :session_queue_id,    presence: true
  end
end
