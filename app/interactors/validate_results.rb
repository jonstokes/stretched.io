class ValidateResults
  include Troupe

  expects :instance, :adapter

  def call
    instance.reject! do |attribute_name, _|
      invalid_properties.include?(attribute_name)
    end
  end

  def invalid_properties
    @invalid_properties ||= errors.map do |error|
      extract_property_from_error(error)
    end
  end

  def errors
    JSON::Validator.fully_validate(adapter.schema, instance, errors_as_objects: true)
  end

  def extract_property_from_error(error)
    error[:fragment].split("/").last
  end
end
