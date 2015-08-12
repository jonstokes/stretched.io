class Dictionary
  include Elasticsearch::Persistence::Model
  include Activisms
  
  attribute :terms, Hash,  mapping: { index: 'object' }

  validates :id, presence: true
end
