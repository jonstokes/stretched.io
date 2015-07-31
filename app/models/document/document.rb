module Document
  class Document < ActiveRecord::Base
    belongs_to :document_queue
    belongs_to :document_adapter
    belongs_to :page
  end
end
