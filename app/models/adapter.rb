class Adapter
  include Elasticsearch::Persistence::Model
  include Activisms

  belongs_to      :schema
  belongs_to      :template, class_name: "Adapter"
  belongs_to_many :scripts

  attribute :property_setters, Hash,   mapping: { type:  'object' }
  attribute :xpath,            String, mapping: { index: 'not_analyzed' }, default: '//html'

  validates :id,               presence: true
  validates :schema_id,        presence: true
  validates :property_setters, presence: true
  validates :xpath,            presence: true

  def runners
    @runners ||= script_ids.map do |script_id|
      Script.runner(script_id) || raise("Adapter: Script #{script_id} not found!")
    end
  end
end
