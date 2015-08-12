class Extension
  include Elasticsearch::Persistence::Model
  include Smelter::Extendable
  include Activisms

  attribute :source, String, mapping: { index: 'not_analyzed' }

  validates :id,     presence: true
  validates :source, presence: true
end
