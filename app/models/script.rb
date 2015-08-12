class Script
  include Elasticsearch::Persistence::Model
  include Smelter::Scriptable
  include Activisms

  attribute :source, String, mapping: { index: 'not_analyzed' }

  validates :id,     presence: true
  validates :source, presence: true

  runner_include Buzzsaw::DSL
end
