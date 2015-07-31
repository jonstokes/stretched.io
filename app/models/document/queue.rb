module Document
  class Queue < ActiveRecord::Base
    self.table_name = 'document_queues'

    belongs_to :rate_limit
    has_many :document_adapters
    has_many :documents
  end
end
