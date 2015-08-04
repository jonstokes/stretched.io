module Document
  class Schema < ActiveRecord::Base
    self.table_name = 'document_schemas'

    META_SCHEMA = Rails.root.join('config', 'schemas', 'v4.json_schema').to_s

    has_many :document_adapters, class_name: "Document::Adapter"

    validates :name, presence: true
    validates :data, presence: true, json: { schema: META_SCHEMA }
  end
end
