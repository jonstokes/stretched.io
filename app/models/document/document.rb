module Document
  class Document < ActiveRecord::Base
    self.table_name = 'documents'

    belongs_to :session_reader, class_name: "Session::Reader"

    validates :session_reader_id,   presence: true
    validates :properties,          presence: true, json: { message: ->(errors) { errors }, schema: :schema }
    validates :page,                presence: true

    attr_accessor :page, :error

    def session
      session_reader.session
    end

    def adapter
      session_reader.document_adapter
    end

    def session_queue
      session_reader.session_queue
    end

    def document_queue
      adapter.queue
    end

    def schema
      adapter.schema
    end
  end
end
