class Extension
  include Elasticsearch::Persistence::Model
  include Smelter::Extendable
  include Activisms
  include NameAsUUID

  attribute :source, String, mapping: { index: 'not_analyzed' }
  validates :source, presence: true
end
