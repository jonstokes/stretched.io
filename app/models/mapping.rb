class Mapping
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :id, :data

  validates :id, :data, presence: true

  def initialize(opts={})
    @id   = opts.delete(:id)
    @data = opts
  end

  def save
    client.indices.put_mapping(
      index: Index.name,
      type:  id,
      body:  to_hash
    )
  end
  alias_method :save!, :save

  def adapters
    self.class.find_by(mapping: self.id)
  end

  def to_hash
    key = data[:properties] ? :properties : 'properties'
    data[key].merge!(
      page_id:    { type: 'string', index: 'not_analyzed' },
      adapter_id: { type: 'string', index: 'not_analyzed' }
    )
    data
  end

  def each_adapter
    self.class.find_each(query: { match: { mapping: self.id } }) do |obj|
      yield obj
    end
  end

  def persisted?; true; end

  def self.find(type)
    response = client.indices.get_mapping(
      index: Index.name,
      type: type
    )
    new_from_response(type: type, response: response)
  end

  def self.all
    response = client.indices.get_mapping(
      index: Index.name
    )
    response[Index.name]['mappings'].map  do |k, v|
      next if Index::MAPPED_CLASSES.include?(k)
      new(v.merge(id: k))
    end.compact
  end

  def self.each
    response = client.indices.get_mapping(
      index: Index.name
    )
    response[Index.name]['mappings'].each do |k, v|
      next if Index::MAPPED_CLASSES.include?(k)
      yield new(v.merge(id: k))
    end
  end

  def self.create(opts)
    self.new(opts).save
  end

  def self.delete(type)
    client.indices.delete_mapping(
      index: Index.name,
      type: type
    )
  end

  def self.new_from_response(type:, response:)
    return unless response
    self.new response[Index.name]['mappings'][type].merge(id: type)
  end

  def client
    self.class.client
  end

  def self.client
    Index.client
  end
end
