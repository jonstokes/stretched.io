module Document
  class Document < ActiveRecord::Base
    self.table_name = 'documents'

    belongs_to :document_adapter, class_name: "Document::Adapter"
    belongs_to :document_queue,   class_name: "Document::Queue"
    belongs_to :page

    validates :document_adapter_id, presence: true
    validates :document_queue_id,   presence: true
    validates :page_id,             presence: true
    validates :properties,          presence: true, json: { schema: :schema }

    def schema
      return {} unless self.document_adapter
      self.document_adapter.schema
    end
  end
end
