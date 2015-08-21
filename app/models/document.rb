class Document
  include Elasticsearch::Persistence::Model
  include Activisms

  belongs_to :page
  belongs_to :adapter

  attribute :properties, Hash, mapping: { type: 'object' }

  validates :id,         presence: true
  validates :page_id,    presence: true
  validates :adapter_id, presence: true
  validates :properties, presence: true
  validate  :properties, :validate_with_schema

  def initialize(opts={})
    opts[:properties] ||= opts['properties']
    if id_source = (opts[:properties].try(:[],'id') || opts[:properties].try(:[],'id'))
      opts[:id] = UUIDTools::UUID.parse_string(id_source).to_s
    end
    super
  end

  def schema
    adapter.try(:schema).try(:data)
  end

  def validate_with_schema
    return unless schema
    JSON::Validator.fully_validate(
      schema,
      properties,
      errors_as_objects: true
    ).each do |err|
      errors.add(:properties, err[:message])
    end
  end
end
