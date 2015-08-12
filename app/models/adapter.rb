class Adapter
  include Elasticsearch::Persistence::Model
  include Activisms

  belongs_to :schema
  belongs_to :template, class_name: "Adapter"

  attribute :attribute_setters,  Hash,   mapping: { type:  'object' }
  attribute :scripts,            Array,  mapping: { type:  'string', index: 'not_analyzed' }
  attribute :xpath,              String, mapping: { index: 'not_analyzed' }

  validates :id,                 presence: true
  validates :schema_id,          presence: true
  validates :attribute_setters,  presence: true

  def runners
    @runners ||= scripts.map do |script_id|
      Script.runner(script_id) || raise("Adapter: Script #{script_id} not found!")
    end
  end

  private

  def check_script_names
    return unless scripts.present?
    scripts.each do |script_id|
      next if Script.find(script_id)
      errors.add(:scripts, "Script #{script_id} not found!")
    end
  end
end
