class ValidateResults
  include Troupe

  expects :instance, :adapter

  def call
    instance.select! do |attribute_name, value|
      adapter.validate_with_schema(attribute_name, value)
    end
  end
end
