class Schema
  include Elasticsearch::Persistence::Model
  include Activisms

  META_SCHEMA = Rails.root.join('config', 'schemas', 'v4.json_schema').to_s

  has_many :adapters

  attribute :data, Hash,   mapping: { type:  'object' }

  validates :id,   presence: true
  validates :data, presence: true, json: { schema: META_SCHEMA }
end
