class AdapterBuilder
  include ActiveModel::Model

  attr_reader :adapter, :attributes

  validates :name, :schema_name, :mapping, :property_setters, presence: true
  delegate  :id, :name, :id_property, :schema_name, :xpath, :mapping, :script_names, :template_name, to: :adapter
  delegate  :to_partial_path, :to_key, :to_model, :to_param, :persisted?, to: :adapter


  (0..15).to_a.each do |i|
    define_method "script_name_#{i}" do
      script_names[i]
    end

    define_method "script_name_#{i}=" do |arg|
      script_names[i] = arg if arg.present?
    end
  end

  def initialize(attrs={})
    @adapter = find_adapter(attrs[:id]) || Adapter.new
    @attributes = attrs
  end

  def update(attrs={})
    adapter.update(attrs)
  end

  def save
    adapter_attributes.each do |k, v|
      adapter.send("#{k}=", v)
    end
    adapter.save
  end

  def property_setters
    adapter.property_setters.try(:to_yaml)
  end

  def adapter_attributes
    attributes.merge(
      roperty_setters: YAML.load(property_setters),
      script_names: [script_names]
    )
  end

  def find_adapter(id)
    return unless id.present?
    Adapter.find(id)
  rescue Elasticsearch::Persistence::Repository::DocumentNotFound
    nil
  end
end