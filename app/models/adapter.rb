class Adapter
  include Elasticsearch::Persistence::Model
  include Activisms
  include NameAsUUID

  gateway do
    def serialize(document)
      doc = super
      doc[:property_setters] = doc[:property_setters].to_yaml
      doc
    end

    def deserialize(document)
      object = klass.new document['_source']

      # Set the meta attributes when fetching the document from Elasticsearch
      #
      object.instance_variable_set :@_id,      document['_id']
      object.instance_variable_set :@_index,   document['_index']
      object.instance_variable_set :@_type,    document['_type']
      object.instance_variable_set :@_version, document['_version']

      # Store the "hit" information (highlighting, score, ...)
      #
      object.instance_variable_set :@hit,
         Hashie::Mash.new(document.except('_index', '_type', '_id', '_version', '_source'))

      object.instance_variable_set(:@persisted, true)
      object.property_setters = YAML.load(object.property_setters) if object.property_setters
      object
    end
  end

  belongs_to      :schema,   by: :name
  belongs_to      :template, by: :name, class_name: "Adapter"
  belongs_to_many :scripts,  by: :name
  has_many        :documents

  attribute :property_setters, String, mapping: { index: 'not_analyzed' }
  attribute :xpath,            String, mapping: { index: 'not_analyzed' }, default: '//html'
  attribute :id_property,      String, mapping: { index: 'not_analyzed' }
  attribute :mapping,          String, mapping: { index: 'not_analyzed' }

  validates :schema_name,        presence: true
  validates :mapping,            presence: true
  validates :property_setters,   presence: true
  validates :xpath,              presence: true
  
  def runners
    @runners ||= script_names.map do |script_name|
      Script.runner(script_name) || raise("Adapter: Script #{script_name} not found!")
    end
  end
end
