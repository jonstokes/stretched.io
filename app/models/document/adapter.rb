module Document
  class Adapter < ActiveRecord::Base
    self.table_name = 'document_adapters'

    belongs_to :document_schema
    belongs_to :document_queue
    has_many :documents
  end
end
