module Document
  class Document < ActiveRecord::Base
    self.table_name = 'documents'

    belongs_to :document_adapter, class_name: "Document::Adapter"
    belongs_to :document_queue,   class_name: "Document::Queue"
    belongs_to :page

    validates :document_adapter_id, presence: true
    validates :document_queue_id,   presence: true
    validates :page_id,             presence: true
    validates :properties,          presence: true
    validate  :properties,          :valid_properties

    private

    def valid_properties
      return if properties.is_a?(Hash)
      errors.add(:properties, "Properties must be a Hash")
    end
  end
end
