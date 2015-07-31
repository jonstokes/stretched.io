module Document
  class Schema < ActiveRecord::Base
    self.table_name = 'document_schemas'

    has_many :document_adapters, class_name: "Document::Adapter"
  end
end
