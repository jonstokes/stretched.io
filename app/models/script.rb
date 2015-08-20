class Script
  include Elasticsearch::Persistence::Model
  include Smelter::Scriptable
  include Activisms
  include NameAsUUID

  attribute :source, String, mapping: { index: 'not_analyzed' }
  validates :source, presence: true

  runner_include Buzzsaw::DSL
end
