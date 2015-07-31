module Document
  class Queue < ActiveRecord::Base
    self.table_name = 'document_queues'

    belongs_to :rate_limit
    has_many :document_adapters, class_name: "Document::Adapter"
    has_many :documents, class_name: "Document::Document"

    validates :name,          presence: true
    validates :max_size,      presence: true, numericality: { greater_than: 0 }
    validates :rate_limit_id, presence: true
  end
end
