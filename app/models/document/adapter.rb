module Document
  class Adapter < ActiveRecord::Base
    include CommonFinders

    self.table_name = 'document_adapters'

    belongs_to :document_schema, class_name: "Document::Schema"
    belongs_to :document_queue,  class_name: "Document::Queue"
    has_many   :documents,       class_name: "Document::Document"

    validates :name,               presence: true
    validates :property_queries,   presence: true
    validates :document_schema_id, presence: true
    validates :document_queue_id,  presence: true

    def runners
      @runners ||= scripts.map do |script_name|
        Script.runner(script_name)
      end
    end

    def scripts
      self[:scripts] || []
    end

    def schema
      document_schema.data
    end
  end
end
