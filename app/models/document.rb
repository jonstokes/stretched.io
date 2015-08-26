class Document
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :id, :type, :page_id, :adapter_id, :properties, :version

  validates :id,         presence: true
  validates :page_id,    presence: true
  validates :adapter_id, presence: true
  validates :properties, presence: true
  validate  :properties, :validate_with_schema

  def initialize(opts={})
    @id         = opts[:id]
    @page_id    = opts[:page_id]
    @adapter_id = opts[:adapter_id]
    @version    = opts[:version]
    @properties = opts[:properties]
    @persisted  = opts[:persisted]
  end

  def persisted?
    !!@persisted
  end

  def adapter
    @adapter ||= Adapter.find(adapter_id)
  end

  def page
    @page ||= Page.find(page_id)
  end

  def mapping
    @mapping ||= adapter.try(:mapping)
  end

  def schema
    adapter.try(:schema).try(:data)
  end

  def save
    Index.client.index(
      index: Index.name,
      type: mapping,
      id:   id,
      body: to_hash
    )
  end
  alias_method :save!, :save

  def to_hash
    properties.merge(
      adapter_id: adapter_id,
      page_id:    page_id
    )
  end

  def self.count
    response = Index.client.search(
      index: Index.name,
      body:  query_body
    )
    response['hits']['total']
  end

  def self.all(opts={})
    response = Index.client.search(
      index: Index.name,
      body:  query_body(opts)
    )
    return [] unless response['hits'].try(:[], 'hits')
    response['hits']['hits'].map { |r| new_from_response(r) }
  end

  def self.each
    response = Index.client.search(
      index: Index.name,
      body:  query_body
    )
    return [] unless response['hits'].try(:[], 'hits')
    response['hits']['hits'].each { |r| yield new_from_response(r) }
  end

  def self.find(id)
    response = Index.client.get(
      index: Index.name,
      id:    id
    )
    new_from_response(response)
  end

  def self.find_by(opts)
    response = Index.client.search(
      index: Index.name,
      body:  {
        query: {
          filtered: {
            filter: {
              and: Index::MAPPED_CLASSES.map { |klass| { not: { type: {value: klass} } } } +
                opts.map { |k, v| { term: { k => v } } }
            }
          }
        },
        sort: { created_at: { order: 'asc'} },
        size: 500
      }
    )
    response['hits']['hits'].map { |r| new_from_response(r) }
  end


  private

  def self.query_body(opts={})
    and_clauses = all_but_mapped_classes
    and_clauses << opts if opts.present?
    {
      query: {
        filtered: {
          filter: {
            and: and_clauses
          }
        }
      },
      sort: { created_at: { order: 'asc'} },
      size: 100
    }
  end

  def self.all_but_mapped_classes
    Index::MAPPED_CLASSES.map { |klass| { not: { type: {value: klass} } } }
  end

  def self.new_from_response(response)
    opts = {
      id:         response['_id'],
      version:    response['_version'],
      page_id:    response['_source'].delete('page_id'),
      adapter_id: response['_source'].delete('adapter_id'),
      properties: response['_source'],
      persisted:  true
    }
    new(opts)
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
