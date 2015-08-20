class Adapter
  include Elasticsearch::Persistence::Model
  include Activisms
  include NameAsUUID

  belongs_to      :schema
  belongs_to      :template, class_name: "Adapter"
  belongs_to_many :scripts

  attribute :property_setters, Hash,   mapping: { type:  'object' }
  attribute :xpath,            String, mapping: { index: 'not_analyzed' }, default: '//html'

  validates :schema_id,        presence: true
  validates :property_setters, presence: true
  validates :xpath,            presence: true

  def runners
    @runners ||= script_names.map do |script_name|
      Script.runner(script_name) || raise("Adapter: Script #{script_name} not found!")
    end
  end
end
